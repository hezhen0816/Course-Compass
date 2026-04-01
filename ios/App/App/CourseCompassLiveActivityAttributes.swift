import ActivityKit
import Foundation

struct CourseCompassLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let courses: [TrackedCourse]

        func resolvedDisplay(referenceDate: Date = Date(), calendar: Calendar = .current) -> ResolvedDisplay? {
            courses
                .compactMap { $0.resolvedDisplay(referenceDate: referenceDate, calendar: calendar) }
                .sorted { $0.countdownTarget < $1.countdownTarget }
                .first
        }
    }

    struct TrackedCourse: Codable, Hashable {
        let title: String
        let subtitle: String
        let room: String
        let timeLabel: String
        let slotTimes: [String]
        let calendarWeekday: Int

        func resolvedDisplay(referenceDate: Date, calendar: Calendar = .current) -> ResolvedDisplay? {
            let todayWeekday = calendar.component(.weekday, from: referenceDate)
            let startOfToday = calendar.startOfDay(for: referenceDate)
            let dayOffset = (calendarWeekday - todayWeekday + 7) % 7

            if let candidate = resolvedDisplay(
                on: calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) ?? startOfToday,
                referenceDate: referenceDate,
                calendar: calendar
            ) {
                return candidate
            }

            let nextWeekDate = calendar.date(byAdding: .day, value: dayOffset + 7, to: startOfToday) ?? startOfToday
            return resolvedDisplay(on: nextWeekDate, referenceDate: referenceDate, calendar: calendar)
        }

        private func resolvedDisplay(on courseDay: Date, referenceDate: Date, calendar: Calendar) -> ResolvedDisplay? {
            let sessions = sessionDateRanges(on: courseDay, calendar: calendar)
            guard let firstSession = sessions.first, let lastSession = sessions.last else {
                return nil
            }

            if referenceDate < firstSession.start {
                return ResolvedDisplay(
                    phase: .beforeClass,
                    title: title,
                    subtitle: subtitle,
                    room: room,
                    timeLabel: timeLabel,
                    countdownTarget: firstSession.start,
                    progressStart: firstSession.start.addingTimeInterval(-3600),
                    progressEnd: firstSession.start
                )
            }

            for (index, session) in sessions.enumerated() {
                if referenceDate < session.start {
                    return ResolvedDisplay(
                        phase: .breakTime,
                        title: title,
                        subtitle: subtitle,
                        room: room,
                        timeLabel: timeLabel,
                        countdownTarget: session.start,
                        progressStart: session.start.addingTimeInterval(-1800),
                        progressEnd: session.start
                    )
                }

                if referenceDate < session.end {
                    return ResolvedDisplay(
                        phase: .inClass,
                        title: title,
                        subtitle: subtitle,
                        room: room,
                        timeLabel: timeLabel,
                        countdownTarget: session.end,
                        progressStart: session.start,
                        progressEnd: session.end
                    )
                }

                if let nextSession = sessions[safe: index + 1], referenceDate < nextSession.start {
                    return ResolvedDisplay(
                        phase: .breakTime,
                        title: title,
                        subtitle: subtitle,
                        room: room,
                        timeLabel: timeLabel,
                        countdownTarget: nextSession.start,
                        progressStart: nextSession.start.addingTimeInterval(-1800),
                        progressEnd: nextSession.start
                    )
                }
            }

            if referenceDate < lastSession.end {
                return ResolvedDisplay(
                    phase: .inClass,
                    title: title,
                    subtitle: subtitle,
                    room: room,
                    timeLabel: timeLabel,
                    countdownTarget: lastSession.end,
                    progressStart: lastSession.start,
                    progressEnd: lastSession.end
                )
            }

            return nil
        }

        private func sessionDateRanges(on courseDay: Date, calendar: Calendar) -> [(start: Date, end: Date)] {
            sessionTimeRanges.compactMap { range in
                guard
                    let start = calendar.date(
                        bySettingHour: range.start.hour ?? 9,
                        minute: range.start.minute ?? 0,
                        second: 0,
                        of: courseDay
                    ),
                    let end = calendar.date(
                        bySettingHour: range.end.hour ?? 10,
                        minute: range.end.minute ?? 0,
                        second: 0,
                        of: courseDay
                    )
                else {
                    return nil
                }

                return (start, end)
            }
        }

        private var sessionTimeRanges: [(start: DateComponents, end: DateComponents)] {
            let rawRanges = slotTimes.isEmpty ? [timeLabel] : slotTimes
            return rawRanges.map { parsedTimeRange($0, fallbackStartHour: 9, fallbackEndHour: 10) }
        }

        private func parsedTimeRange(_ label: String, fallbackStartHour: Int, fallbackEndHour: Int) -> (start: DateComponents, end: DateComponents) {
            let matches = label.matches(of: /(\d{1,2}):(\d{2})/)
            if matches.count >= 2 {
                let start = matches[0]
                let end = matches[1]
                return (
                    DateComponents(
                        hour: Int(start.output.1) ?? fallbackStartHour,
                        minute: Int(start.output.2) ?? 0
                    ),
                    DateComponents(
                        hour: Int(end.output.1) ?? fallbackEndHour,
                        minute: Int(end.output.2) ?? 0
                    )
                )
            }

            let pieces = label
                .replacingOccurrences(of: "～", with: "-")
                .replacingOccurrences(of: "~", with: "-")
                .components(separatedBy: "-")
            let startLabel = pieces.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "\(fallbackStartHour):00"
            let endLabel = pieces.dropFirst().first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "\(fallbackEndHour):00"

            return (
                parseSingleTime(startLabel, fallbackHour: fallbackStartHour),
                parseSingleTime(endLabel, fallbackHour: fallbackEndHour)
            )
        }

        private func parseSingleTime(_ label: String, fallbackHour: Int) -> DateComponents {
            if let match = label.firstMatch(of: /(\d{1,2}):(\d{2})/) {
                return DateComponents(
                    hour: Int(match.output.1) ?? fallbackHour,
                    minute: Int(match.output.2) ?? 0
                )
            }

            let parts = label.split(separator: ":")
            let hour = Int(parts.first ?? Substring("\(fallbackHour)")) ?? fallbackHour
            let minute = Int(parts.dropFirst().first ?? "0") ?? 0
            return DateComponents(hour: hour, minute: minute)
        }
    }

    struct ResolvedDisplay: Hashable {
        let phase: Phase
        let title: String
        let subtitle: String
        let room: String
        let timeLabel: String
        let countdownTarget: Date
        let progressStart: Date
        let progressEnd: Date

        func progressFraction(referenceDate: Date = Date()) -> Double {
            let total = progressEnd.timeIntervalSince(progressStart)
            guard total > 0 else {
                return 1
            }

            let elapsed = referenceDate.timeIntervalSince(progressStart)
            return min(max(elapsed / total, 0), 1)
        }
    }

    enum Phase: String, Codable, Hashable {
        case beforeClass
        case inClass
        case breakTime

        var title: String {
            switch self {
            case .beforeClass:
                return "距離上課"
            case .inClass:
                return "距離下課"
            case .breakTime:
                return "距離下節"
            }
        }

        var subtitle: String {
            switch self {
            case .beforeClass:
                return "即將開始"
            case .inClass:
                return "正在上課"
            case .breakTime:
                return "下課空檔"
            }
        }

        var compactLabel: String {
            switch self {
            case .beforeClass:
                return "上課"
            case .inClass:
                return "下課"
            case .breakTime:
                return "下節"
            }
        }
    }

    let studentName: String
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}

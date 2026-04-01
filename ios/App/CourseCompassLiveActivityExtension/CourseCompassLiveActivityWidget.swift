import ActivityKit
import SwiftUI
import WidgetKit

struct CourseCompassLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CourseCompassLiveActivityAttributes.self) { context in
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                if let display = context.state.resolvedDisplay(referenceDate: timeline.date) {
                    lockScreenView(for: display, referenceDate: timeline.date)
                        .activityBackgroundTint(Color(red: 0.12, green: 0.17, blue: 0.28))
                        .activitySystemActionForegroundColor(.white)
                } else {
                    fallbackView
                        .activityBackgroundTint(Color(red: 0.12, green: 0.17, blue: 0.28))
                        .activitySystemActionForegroundColor(.white)
                }
            }
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading, priority: 2) {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        if let display = context.state.resolvedDisplay(referenceDate: timeline.date) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(display.phase.subtitle)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                ViewThatFits(in: .horizontal) {
                                    titleText(display.title, font: .title2.weight(.bold))
                                    titleText(display.title, font: .title3.weight(.bold))
                                    titleText(display.title, font: .headline.weight(.bold))
                                    titleText(display.title, font: .subheadline.weight(.bold))
                                }
                            }
                            .padding(.leading, 6)
                            .padding(.top, 4)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing, priority: 1) {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        if let display = context.state.resolvedDisplay(referenceDate: timeline.date) {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(display.phase.title)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                countdownText(for: display, referenceDate: timeline.date)
                                    .font(.title3.weight(.bold))
                                    .monospacedDigit()
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .frame(minWidth: 84, idealWidth: 92, maxWidth: 96, alignment: .trailing)
                            .padding(.trailing, 6)
                            .padding(.top, 4)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        if let display = context.state.resolvedDisplay(referenceDate: timeline.date) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 12) {
                                    Label(display.timeLabel, systemImage: "clock.fill")
                                    Label(display.room, systemImage: "mappin.and.ellipse")
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.92))

                                ProgressView(value: display.progressFraction(referenceDate: timeline.date))
                                    .tint(Color.cyan)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 4)
                        }
                    }
                }
            } compactLeading: {
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    if let display = context.state.resolvedDisplay(referenceDate: timeline.date) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: 10, height: 10)
                            Text(display.phase.compactLabel)
                                .font(.caption2.weight(.semibold))
                                .lineLimit(1)
                                .foregroundStyle(.white.opacity(0.82))
                        }
                    }
                }
            } compactTrailing: {
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    if let display = context.state.resolvedDisplay(referenceDate: timeline.date) {
                        countdownText(for: display, referenceDate: timeline.date)
                            .font(.caption2.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 54, alignment: .trailing)
                    }
                }
            } minimal: {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.white)
            }
            .keylineTint(.cyan)
        }
    }

    @ViewBuilder
    private func lockScreenView(for display: CourseCompassLiveActivityAttributes.ResolvedDisplay, referenceDate: Date = Date()) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(display.phase.subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                    ViewThatFits(in: .horizontal) {
                        titleText(display.title, font: .title3.weight(.bold))
                        titleText(display.title, font: .headline.weight(.bold))
                        titleText(display.title, font: .subheadline.weight(.bold))
                        titleText(display.title, font: .footnote.weight(.bold))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(display.phase.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    countdownText(for: display, referenceDate: referenceDate)
                        .font(.headline.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(minWidth: 88, idealWidth: 96, maxWidth: 104, alignment: .trailing)
            }

            HStack(spacing: 14) {
                Label(display.timeLabel, systemImage: "clock.fill")
                Label(display.room, systemImage: "mappin.and.ellipse")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white.opacity(0.92))

            ProgressView(value: display.progressFraction(referenceDate: referenceDate))
                .tint(.cyan)
                .labelsHidden()
        }
        .padding(18)
    }

    @ViewBuilder
    private func countdownText(for display: CourseCompassLiveActivityAttributes.ResolvedDisplay, referenceDate: Date) -> some View {
        Text(timerInterval: referenceDate...display.countdownTarget, countsDown: true)
    }

    private func titleText(_ title: String, font: Font) -> some View {
        Text(title)
            .font(font)
            .foregroundStyle(.white)
            .allowsTightening(true)
            .lineLimit(1)
            .truncationMode(.tail)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fallbackView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今天沒有剩餘課程")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            Text("課表更新後會自動恢復倒數。")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.78))
        }
        .padding(18)
    }
}

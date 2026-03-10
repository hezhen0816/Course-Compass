import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppSessionStore
    @State private var infoMessage: InfoMessage?
    @State private var isTargetSheetPresented = false
    @State private var isSyncing = false

    var body: some View {
        Form {
            Section("Supabase 帳號") {
                LabeledContent("目前登入", value: store.currentUserEmail ?? "未登入")

                if let authNoticeMessage = store.authNoticeMessage {
                    Text(authNoticeMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("學校帳密設定") {
                TextField("學號 / 校務帳號", text: $store.schoolAccount)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                SecureField("密碼", text: $store.schoolPassword)

                TextField("Python 後端網址", text: $store.backendBaseURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.URL)

                Text("會把帳密送到你自己的 Python 後端，由後端登入校務系統並可選擇寫入 Supabase。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("同步") {
                Button {
                    isSyncing = true
                    Task {
                        await store.syncSchedule()
                        isSyncing = false
                    }
                } label: {
                    settingsRow(
                        title: isSyncing ? "同步中..." : "同步課表",
                        subtitle: "登入校務後寫入 Supabase 快照",
                        symbol: "arrow.triangle.2.circlepath"
                    )
                }
                .disabled(isSyncing)

                Button {
                    isSyncing = true
                    Task {
                        await store.loadLatestScheduleSnapshot()
                        isSyncing = false
                    }
                } label: {
                    settingsRow(title: "讀取最新快照", subtitle: "直接從 Supabase 讀取已同步課表", symbol: "tray.and.arrow.down")
                }
                .buttonStyle(.plain)
                .disabled(isSyncing)

                if case .failed(let message) = store.syncState {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                } else {
                    Text(syncStatusDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("提醒") {
                Picker("課前提醒", selection: $store.reminderMinutes) {
                    ForEach([5, 10, 15, 30, 60], id: \.self) { minutes in
                        Text("\(minutes) 分鐘前").tag(minutes)
                    }
                }

                Text("提醒設定只保存於本次 App 執行期間，不建立本地通知。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("學分規劃") {
                Button {
                    isTargetSheetPresented = true
                } label: {
                    settingsRow(title: "設定畢業門檻", subtitle: "可編輯本地 session 狀態", symbol: "slider.horizontal.3")
                }

                let progress = store.plannerProgress
                VStack(alignment: .leading, spacing: 10) {
                    Text("目前進度摘要")
                        .font(.subheadline.weight(.semibold))
                    PlannerProgressRow(title: "總學分", current: progress.total, target: store.plannerTargets.total, tint: .blue)
                    PlannerProgressRow(title: "通識", current: progress.genEd, target: store.plannerTargets.genEd, tint: .purple)
                    PlannerProgressRow(title: "本系必修", current: progress.homeCompulsory, target: store.plannerTargets.homeCompulsory, tint: .red)
                }
                .padding(.vertical, 6)
            }

            Section("功能導覽") {
                Button {
                    infoMessage = InfoMessage(title: "功能導覽", message: "目前已接入 Python 後端課表同步；學分規劃與待辦仍是本地資料。")
                } label: {
                    settingsRow(title: "查看功能導覽", subtitle: "說明哪些資料已接真實同步", symbol: "book.closed")
                }
            }

            Section {
                Button(role: .destructive) {
                    Task {
                        await store.signOut()
                    }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("登出 Supabase")
                    }
                }
            }
        }
        .navigationTitle("設定")
        .alert(item: $infoMessage) { message in
            Alert(
                title: Text(message.title),
                message: Text(message.message),
                dismissButton: .default(Text("知道了"))
            )
        }
        .sheet(isPresented: $isTargetSheetPresented) {
            TargetSettingsSheet(
                initialTargets: store.plannerTargets,
                onSave: { targets in
                    store.updateTargets(targets)
                }
            )
        }
    }

    private func settingsRow(title: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(.indigo)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }

    private var syncStatusDescription: String {
        if let lastSyncedAt = store.lastSyncedAt {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_Hant_TW")
            formatter.dateFormat = "M/d HH:mm"
            return "\(store.syncState.label)・上次同步 \(formatter.string(from: lastSyncedAt))"
        }
        return store.syncState.label
    }
}

import SwiftUI

struct AppShellView: View {
    @StateObject private var store = AppSessionStore()

    var body: some View {
        Group {
            if store.isRestoringSession {
                ProgressView("正在恢復登入狀態...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if !store.isAuthenticated {
                AuthGateView()
            } else {
                authenticatedShell
            }
        }
        .environmentObject(store)
    }

    private var authenticatedShell: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.systemImage)
            }
            .tag(AppTab.home)

            NavigationStack {
                ScheduleView()
            }
            .tabItem {
                Label(AppTab.schedule.title, systemImage: AppTab.schedule.systemImage)
            }
            .tag(AppTab.schedule)

            NavigationStack {
                PlannerView()
            }
            .tabItem {
                Label(AppTab.planner.title, systemImage: AppTab.planner.systemImage)
            }
            .tag(AppTab.planner)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage)
            }
            .tag(AppTab.settings)
        }
        .tint(.indigo)
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.footnote.weight(.bold))
                Text(store.lastSyncedAt == nil ? "已登入 Supabase" : store.subtitle)
                    .font(.footnote.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(.indigo)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .overlay(alignment: .bottom) {
                Divider()
            }
        }
    }
}

private struct AuthGateView: View {
    @EnvironmentObject private var store: AppSessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var authMode: AuthFormMode = .login

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("修課規劃助手")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("iOS 版現在改用和 Web 類似的 Supabase Email/Password 登入，學分規劃資料會跟著帳號保存。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        SecureField("密碼", text: $password)
                            .textContentType(.password)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Button {
                            Task {
                                if authMode == .login {
                                    await store.signIn(email: email, password: password)
                                } else {
                                    await store.signUp(email: email, password: password)
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text(store.isAuthenticating ? "處理中..." : authMode.title)
                                    .font(.headline.weight(.semibold))
                                Spacer()
                            }
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .disabled(store.isAuthenticating || !store.isAuthConfigured)

                        if let authErrorMessage = store.authErrorMessage {
                            Label(authErrorMessage, systemImage: "exclamationmark.triangle.fill")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        if let authNoticeMessage = store.authNoticeMessage {
                            Label(authNoticeMessage, systemImage: "checkmark.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(.green)
                        }

                        if !store.isAuthConfigured {
                            Label("iOS 尚未設定 Supabase URL / Anon Key", systemImage: "gearshape.2.fill")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                        }

                        Button(authMode.toggleTitle) {
                            authMode = authMode == .login ? .signup : .login
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.indigo)
                    }
                    .padding(20)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

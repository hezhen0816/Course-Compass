import SwiftUI

struct AppShellView: View {
    @StateObject private var store = AppSessionStore()

    var body: some View {
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
                Text("展示版：目前修改只保留本次開啟")
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
        .environmentObject(store)
    }
}

import SwiftUI

@main
struct HouseRentClientApp: App {
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoadingUser {
                LoadingView()
            } else if appState.currentUser == nil {
                LoginView()
                    .environmentObject(appState)
            } else {
                MainTabView()
                    .environmentObject(appState)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ChatListView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
            
            VisitsListView()
                .tabItem {
                    Label("Visits", systemImage: "calendar")
                }
            
            ApplicationsListView()
                .tabItem {
                    Label("Applications", systemImage: "doc.text")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(Color.appPrimary)
    }
}

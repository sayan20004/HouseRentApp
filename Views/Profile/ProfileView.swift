//
//  ProfileView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(appState.currentUser?.name ?? "User")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(appState.currentUser?.role.rawValue.capitalized ?? "")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.appPrimary.opacity(0.1))
                                .foregroundColor(.appPrimary)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Account") {
                    Text(appState.currentUser?.email ?? "")
                    Text(appState.currentUser?.phone ?? "")
                }
                
                if appState.currentUser?.role == .owner {
                    Section("Owner Tools") {
                        NavigationLink(destination: OwnerPropertiesView()) {
                            Label("My Properties", systemImage: "building.2")
                        }
                    }
                }
                
                Section {
                    Button("Logout") {
                        appState.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

//
//  ApplicationsListView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI
import Combine
@MainActor
class ApplicationsViewModel: ObservableObject {
    @Published var applications: [RentalApplication] = []
    @Published var isLoading = false
    
    func loadData(userRole: UserRole) {
        isLoading = true
        Task {
            do {
                applications = try await ApplicationService.shared.fetchMyApplications(role: userRole)
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}

struct ApplicationsListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ApplicationsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.applications.isEmpty {
                    EmptyStateView(text: "No applications found")
                } else {
                    List(viewModel.applications) { app in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(app.property.title)
                                    .font(.headline)
                                Spacer()
                                Text(app.status.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(6)
                                    .background(app.status.color.opacity(0.2))
                                    .foregroundColor(app.status.color)
                                    .cornerRadius(4)
                            }
                            
                            if let offer = app.monthlyRentOffered {
                                Text("Offered: ₹\(offer)")
                                    .font(.subheadline)
                                    .foregroundColor(.appPrimary)
                            }
                            
                            Text(app.message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Applications")
            .onAppear {
                if let role = appState.currentUser?.role {
                    viewModel.loadData(userRole: role)
                }
            }
        }
    }
}

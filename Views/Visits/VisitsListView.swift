//
//  VisitsListView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI
import Combine
@MainActor
class VisitsViewModel: ObservableObject {
    @Published var visits: [VisitRequest] = []
    @Published var isLoading = false
    
    func loadData(userRole: UserRole) {
        isLoading = true
        Task {
            do {
                visits = try await VisitService.shared.fetchMyVisits(role: userRole)
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}

struct VisitsListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = VisitsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.visits.isEmpty {
                    EmptyStateView(text: "No visits scheduled")
                } else {
                    List(viewModel.visits) { visit in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(visit.property.title)
                                    .font(.headline)
                                Spacer()
                                Text(visit.status.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(6)
                                    .background(visit.status.color.opacity(0.2))
                                    .foregroundColor(visit.status.color)
                                    .cornerRadius(4)
                            }
                            
                            Text(formatDate(visit.preferredDateTime))
                                .font(.subheadline)
                            
                            if let notes = visit.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("My Visits")
            .onAppear {
                if let role = appState.currentUser?.role {
                    viewModel.loadData(userRole: role)
                }
            }
        }
    }
    
    func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
        return iso
    }
}

struct EmptyStateView: View {
    let text: String
    var body: some View {
        VStack {
            Image(systemName: "list.bullet.clipboard")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .padding()
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

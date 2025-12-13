//
//  VisitsListView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI
import Combine

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
                                Text(visit.property.title).font(.headline)
                                Spacer()
                                Text(visit.status.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(6)
                                    .background(visit.status.color.opacity(0.2))
                                    .foregroundColor(visit.status.color)
                                    .cornerRadius(4)
                            }
                            Text(formatDate(visit.preferredDateTime)).font(.subheadline)
                            if let notes = visit.notes, !notes.isEmpty {
                                Text(notes).font(.caption).foregroundColor(.secondary)
                            }
                            
                            if appState.currentUser?.role == .owner && visit.status == .pending {
                                HStack {
                                    Button("Accept") {
                                        updateStatus(id: visit.id, status: "accepted")
                                    }.buttonStyle(.borderedProminent).tint(.green)
                                    
                                    Button("Reject") {
                                        updateStatus(id: visit.id, status: "rejected")
                                    }.buttonStyle(.bordered).tint(.red)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(appState.currentUser?.role == .owner ? "Visit Requests" : "My Visits")
            .onAppear {
                if let role = appState.currentUser?.role {
                    viewModel.loadData(userRole: role)
                }
            }
        }
    }
    
    func updateStatus(id: String, status: String) {
        Task {
            try? await VisitService.shared.updateStatus(id: id, status: status)
            if let role = appState.currentUser?.role {
                viewModel.loadData(userRole: role)
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

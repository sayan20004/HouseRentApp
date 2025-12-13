//
//  OwnerPropertiesView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//



import SwiftUI
import Combine

@MainActor
class OwnerPropertiesViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    
    func load() {
        isLoading = true
        Task {
            do {
                properties = try await PropertyService.shared.fetchOwnerProperties()
            } catch {
                print("Error loading owner properties: \(error)")
            }
            isLoading = false
        }
    }
}

struct OwnerPropertiesView: View {
    @StateObject private var viewModel = OwnerPropertiesViewModel()
    @State private var showingAddProperty = false
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.properties.isEmpty {
                VStack {
                    EmptyStateView(text: "You haven't posted any properties")
                    Button("Add Property") {
                        showingAddProperty = true
                    }
                    .padding()
                }
            } else {
                List(viewModel.properties) { property in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(property.title)
                                .font(.headline)
                            Text(property.status.capitalized)
                                .font(.caption)
                                .foregroundColor(property.status == "active" ? .green : .orange)
                        }
                        Spacer()
                        Text("₹\(property.rent)")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .navigationTitle("My Properties")
        .toolbar {
            Button(action: { showingAddProperty = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddProperty) {
            AddPropertyView()
        }
        .onAppear { viewModel.load() }
        .onChange(of: showingAddProperty) { isPresented in
            // Reload list when AddPropertyView is dismissed to show the new property
            if !isPresented {
                viewModel.load()
            }
        }
    }
}

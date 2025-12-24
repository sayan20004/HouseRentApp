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
    
    func deleteProperty(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let property = properties[index]
        
        Task {
            do {
                try await PropertyService.shared.deleteProperty(id: property.id)
                self.properties.remove(at: index)
            } catch {
                print("Error deleting property: \(error)")
                load()
            }
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
                List {
                    ForEach(viewModel.properties) { property in
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
                    .onDelete(perform: viewModel.deleteProperty)
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
            if !isPresented {
                viewModel.load()
            }
        }
    }
}

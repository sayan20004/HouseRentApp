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
                print(error)
            }
            isLoading = false
        }
    }
}

struct OwnerPropertiesView: View {
    @StateObject private var viewModel = OwnerPropertiesViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
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
                    }
                }
            }
        }
        .navigationTitle("My Properties")
        .onAppear { viewModel.load() }
    }
}

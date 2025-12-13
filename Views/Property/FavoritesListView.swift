//
//  FavoritesListView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import SwiftUI
import Combine
@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []
    @Published var isLoading = false
    
    func loadData() {
        isLoading = true
        Task {
            do {
                favorites = try await FavoriteService.shared.fetchFavorites()
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
    
    func remove(id: String) {
        Task {
            try? await FavoriteService.shared.removeFavorite(propertyId: id)
            loadData()
        }
    }
}

struct FavoritesListView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.favorites.isEmpty {
                    VStack {
                        Image(systemName: "heart.slash")
                            .font(.largeTitle)
                            .padding()
                        Text("No favorites yet")
                    }
                } else {
                    List(viewModel.favorites) { favorite in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(favorite.property.title)
                                    .font(.headline)
                                Text("₹\(favorite.property.rent)/mo")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Button(action: { viewModel.remove(id: favorite.property.id) }) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .onAppear { viewModel.loadData() }
        }
    }
}

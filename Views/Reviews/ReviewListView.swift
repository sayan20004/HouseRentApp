//
//  ReviewListView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 27/12/25.
//

import SwiftUI
import Combine

class ReviewListViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    
    func loadReviews(propertyId: String) {
        isLoading = true
        Task {
            do {
                reviews = try await ReviewService.shared.fetchReviews(propertyId: propertyId)
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }
}

struct ReviewListView: View {
    let propertyId: String
    @StateObject private var viewModel = ReviewListViewModel()
    @State private var showWriteReview = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Reviews")
                    .font(.headline)
                Spacer()
                if viewModel.averageRating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundColor(.orange)
                        Text(String(format: "%.1f", viewModel.averageRating))
                            .fontWeight(.bold)
                        Text("(\(viewModel.reviews.count))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView().padding()
            } else if viewModel.reviews.isEmpty {
                Text("No reviews yet.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.reviews) { review in
                            ReviewCard(review: review)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Button("Write a Review") {
                showWriteReview = true
            }
            .font(.subheadline)
            .padding(.horizontal)
            .padding(.top, 4)
        }
        .onAppear { viewModel.loadReviews(propertyId: propertyId) }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(propertyId: propertyId, onSubmitted: {
                viewModel.loadReviews(propertyId: propertyId)
            })
        }
    }
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.reviewer.name)
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            if let comment = review.comment, !comment.isEmpty {
                Text(comment)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(12)
        .frame(width: 250)
        .background(Color.appBackground)
        .cornerRadius(8)
    }
}

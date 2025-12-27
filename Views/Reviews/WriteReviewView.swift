//
//  WriteReviewView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 27/12/25.
//

import SwiftUI

struct WriteReviewView: View {
    let propertyId: String
    var onSubmitted: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var rating = 5
    @State private var comment = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    HStack {
                        Spacer()
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                                .onTapGesture {
                                    rating = index
                                }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Comment (Optional)")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }
                
                Button(action: submit) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Submit Review")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                    }
                }
                .disabled(isSubmitting)
            }
            .navigationTitle("Write Review")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func submit() {
        isSubmitting = true
        Task {
            try? await ReviewService.shared.submitReview(propertyId: propertyId, rating: rating, comment: comment)
            await MainActor.run {
                isSubmitting = false
                onSubmitted()
                dismiss()
            }
        }
    }
}

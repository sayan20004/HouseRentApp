//
//  Components.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appPrimary)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
struct EmptyStateView: View {
    let text: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            Text(text)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

//
//  PropertyDetailView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI

struct PropertyDetailView: View {
    @StateObject private var viewModel: PropertyDetailViewModel
    @State private var showVisitSheet = false
    @State private var showApplicationSheet = false
    
    init(property: Property) {
        _viewModel = StateObject(wrappedValue: PropertyDetailViewModel(property: property))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image Header
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            AsyncImage(url: URL(string: viewModel.property.images.first ?? "")) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Image(systemName: "house.fill")
                            }
                        )
                        .clipped()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(viewModel.property.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(viewModel.property.location.area), \(viewModel.property.location.city)")
                            .font(.body)
                            .foregroundColor(.textSecondary)
                        
                        Divider()
                        
                        // Rent Box
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Rent")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                Text("₹\(viewModel.property.rent)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Deposit")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                Text("₹\(viewModel.property.securityDeposit)")
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(Color.appBackground)
                        .cornerRadius(8)
                        
                        // Details Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            DetailItem(title: "BHK", value: "\(viewModel.property.bhk)")
                            DetailItem(title: "Type", value: viewModel.property.propertyType.displayName)
                            DetailItem(title: "Area", value: "\(viewModel.property.builtUpArea) sqft")
                            DetailItem(title: "Furnishing", value: viewModel.property.furnishing.displayName)
                            DetailItem(title: "For", value: viewModel.property.allowedTenants.displayName)
                        }
                        
                        Divider()
                        
                        Text("Amenities")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.property.amenities, id: \.self) { amenity in
                                    Text(amenity)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.appBackground)
                                        .cornerRadius(16)
                                }
                            }
                        }
                        
                        Divider()
                        
                        Text("About")
                            .font(.headline)
                        Text(viewModel.property.description)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                        
                        Spacer(minLength: 80)
                    }
                    .padding()
                }
            }
            
            // Bottom Action Bar
            VStack {
                HStack(spacing: 16) {
                    Button(action: { showVisitSheet = true }) {
                        Text("Book Visit")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appPrimary, lineWidth: 2))
                            .foregroundColor(.appPrimary)
                    }
                    
                    Button(action: { showApplicationSheet = true }) {
                        Text("Apply Now")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white.shadow(radius: 4, y: -2))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showVisitSheet) {
            BookVisitView(viewModel: viewModel)
        }
        .sheet(isPresented: $showApplicationSheet) {
            ApplyRentView(viewModel: viewModel)
        }
    }
}

struct DetailItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

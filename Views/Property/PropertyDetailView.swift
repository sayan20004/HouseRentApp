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
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            AsyncImage(url: URL(string: viewModel.property.images.first ?? "")) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Image(systemName: "house.fill")
                                    .foregroundColor(.gray)
                            }
                        )
                        .clipped()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(viewModel.property.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                            Spacer()
                            
                            Button(action: { viewModel.addToFavorites() }) {
                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(viewModel.isFavorite ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                        
                        Text("\(viewModel.property.location.area), \(viewModel.property.location.city)")
                            .font(.body)
                            .foregroundColor(.textSecondary)
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Rent")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                Text("₹\(viewModel.property.rent)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Deposit")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                Text("₹\(viewModel.property.securityDeposit)")
                                    .font(.headline)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .padding()
                        .background(Color.appBackground)
                        .cornerRadius(12)
                        
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
                            .foregroundColor(.textPrimary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.property.amenities, id: \.self) { amenity in
                                    Text(amenity)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.appBackground)
                                        .foregroundColor(.textPrimary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        
                        Divider()
                        
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        Text(viewModel.property.description)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .lineSpacing(4)
                        
                        Spacer(minLength: 120)
                    }
                    .padding()
                }
            }
            .background(Color.white)
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { showVisitSheet = true }) {
                        Text("Book Visit")
                            .fontWeight(.bold)
                            .foregroundColor(.appPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial)
                            .background(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Button(action: { showApplicationSheet = true }) {
                        Text("Apply Now")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: [Color.appPrimary, Color.appPrimary.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    LinearGradient(
                                        colors: [.white.opacity(0.35), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                    .mask(RoundedRectangle(cornerRadius: 20))
                                    .padding(.top, 1)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.appPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
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
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.appBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

import SwiftUI
import MapKit

struct PropertyDetailView: View {
    @StateObject private var viewModel: PropertyDetailViewModel
    @EnvironmentObject var appState: AppState
    @State private var showVisitSheet = false
    @State private var showApplicationSheet = false
    
    // Chat State
    @State private var navigateToChat = false
    @State private var activeConversation: Conversation?
    
    // Map State
    @State private var region: MKCoordinateRegion
    
    init(property: Property) {
        _viewModel = StateObject(wrappedValue: PropertyDetailViewModel(property: property))
        
        let lat = property.location.geo?.lat ?? 28.6139
        let lng = property.location.geo?.lng ?? 77.2090
        
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Property Image
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
                        // Title & Favorite
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
                        
                        // Financials
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
                        
                        // Details Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            DetailItem(title: "BHK", value: "\(viewModel.property.bhk)")
                            DetailItem(title: "Type", value: viewModel.property.propertyType.displayName)
                            DetailItem(title: "Area", value: "\(viewModel.property.builtUpArea) sqft")
                            DetailItem(title: "Furnishing", value: viewModel.property.furnishing.displayName)
                            DetailItem(title: "For", value: viewModel.property.allowedTenants.displayName)
                        }
                        
                        Divider()
                        
                        // Amenities
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
                        
                        // Location Map
                        Text("Location")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Map(coordinateRegion: $region, annotationItems: [viewModel.property]) { prop in
                            MapMarker(coordinate: CLLocationCoordinate2D(
                                latitude: prop.location.geo?.lat ?? 0,
                                longitude: prop.location.geo?.lng ?? 0
                            ))
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        
                        Divider()
                        
                        // Reviews Section
                        ReviewListView(propertyId: viewModel.property.id)
                        
                        Divider()
                        
                        // Description
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
            
            // Bottom Action Bar
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Chat Button (Only if not owner)
                    if appState.currentUser?.id != viewModel.property.owner._id {
                        Button(action: startChat) {
                            VStack {
                                Image(systemName: "message.fill")
                                Text("Chat")
                            }
                            .font(.caption)
                            .padding()
                            .background(Color.appBackground)
                            .foregroundColor(.appPrimary)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button(action: { showVisitSheet = true }) {
                        Text("Book Visit")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.appPrimary)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appPrimary, lineWidth: 1))
                            .cornerRadius(12)
                    }
                    
                    Button(action: { showApplicationSheet = true }) {
                        Text("Apply")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
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
        .navigationDestination(isPresented: $navigateToChat) {
            if let conversation = activeConversation {
                ChatDetailView(conversation: conversation)
            }
        }
    }
    
    func startChat() {
        Task {
            do {
                let conversation = try await ChatService.shared.startConversation(
                    propertyId: viewModel.property.id,
                    ownerId: viewModel.property.owner._id
                )
                await MainActor.run {
                    self.activeConversation = conversation
                    self.navigateToChat = true
                }
            } catch {
                print("Error starting chat: \(error)")
            }
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

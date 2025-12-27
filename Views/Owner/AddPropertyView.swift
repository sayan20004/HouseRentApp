import SwiftUI
import Combine
import PhotosUI
import MapKit
import CoreLocation

class AddPropertyViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var propertyType = PropertyType.apartment
    @Published var bhk = 1
    @Published var furnishing = Furnishing.unfurnished
    @Published var rent = ""
    @Published var deposit = ""
    
    @Published var maintenanceAmount = ""
    @Published var maintenanceIncluded = false
    
    @Published var area = ""
    @Published var city = ""
    @Published var locationArea = ""
    @Published var pincode = ""
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var allowedTenants = AllowedTenants.any
    @Published var availableDate = Date()
    
    @Published var selectedAmenities: Set<String> = []
    let availableAmenities = ["Wifi", "Parking", "Lift", "Gym", "Security", "Power Backup", "Swimming Pool", "Garden"]
    
    @Published var isSubmitting = false
    @Published var shouldDismiss = false
    @Published var errorMsg: String?
    
    func toggleAmenity(_ amenity: String) {
        if selectedAmenities.contains(amenity) {
            selectedAmenities.remove(amenity)
        } else {
            selectedAmenities.insert(amenity)
        }
    }
    
    func submit(imagesData: [Data]) {
        guard let rentInt = Int(rent),
              let depositInt = Int(deposit),
              let areaInt = Int(area) else {
            errorMsg = "Please enter valid numbers for Rent, Deposit, and Area"
            return
        }
        
        let maintenanceInt = Int(maintenanceAmount) ?? 0
        
        if title.count < 10 { errorMsg = "Title must be at least 10 chars"; return }
        if description.count < 50 { errorMsg = "Description must be at least 50 chars"; return }
        if city.isEmpty || locationArea.isEmpty || pincode.count != 6 { errorMsg = "Please enter valid location details"; return }
        
        let geo = GeoInput(lat: region.center.latitude, lng: region.center.longitude)
        
        let location = LocationInput(city: city, area: locationArea, pincode: pincode, geo: geo)
        
        let maintenance = MaintenanceInput(amount: maintenanceInt, included: maintenanceIncluded)
        
        let input = PropertyInput(
            title: title,
            description: description,
            propertyType: propertyType.rawValue,
            bhk: bhk,
            furnishing: furnishing.rawValue,
            rent: rentInt,
            securityDeposit: depositInt,
            maintenance: maintenance,
            builtUpArea: areaInt,
            availableFrom: ISO8601DateFormatter().string(from: availableDate),
            location: location,
            amenities: Array(selectedAmenities),
            images: [],
            allowedTenants: allowedTenants.rawValue
        )
        
        isSubmitting = true
        Task {
            do {
                try await PropertyService.shared.createProperty(input, imagesData: imagesData)
                await MainActor.run { shouldDismiss = true }
            } catch {
                await MainActor.run { errorMsg = error.localizedDescription }
            }
            await MainActor.run { isSubmitting = false }
        }
    }
    
    func geocodeAddress() {
        let geocoder = CLGeocoder()
        let address = "\(locationArea), \(city), \(pincode)"
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self?.region.center = coordinate
                }
            }
        }
    }
}

struct AddPropertyView: View {
    @StateObject private var viewModel = AddPropertyViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Details")) {
                    TextField("Title (Min 10 chars)", text: $viewModel.title)
                    TextField("Description (Min 50 chars)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Type", selection: $viewModel.propertyType) {
                        ForEach(PropertyType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    Stepper("BHK: \(viewModel.bhk)", value: $viewModel.bhk, in: 1...10)
                }
                
                Section(header: Text("Financials & Area")) {
                    TextField("Rent", text: $viewModel.rent).keyboardType(.numberPad)
                    TextField("Deposit", text: $viewModel.deposit).keyboardType(.numberPad)
                    
                    Toggle("Maintenance Included", isOn: $viewModel.maintenanceIncluded)
                    if !viewModel.maintenanceIncluded {
                        TextField("Maintenance Amount", text: $viewModel.maintenanceAmount).keyboardType(.numberPad)
                    }
                    
                    TextField("Area (sqft)", text: $viewModel.area).keyboardType(.numberPad)
                    Picker("Furnishing", selection: $viewModel.furnishing) {
                        ForEach(Furnishing.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Amenities")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(viewModel.availableAmenities, id: \.self) { amenity in
                            Button(action: { viewModel.toggleAmenity(amenity) }) {
                                Text(amenity)
                                    .font(.caption)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(viewModel.selectedAmenities.contains(amenity) ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.selectedAmenities.contains(amenity) ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Location")) {
                    TextField("City", text: $viewModel.city)
                    TextField("Area", text: $viewModel.locationArea)
                    TextField("Pincode (6 digits)", text: $viewModel.pincode).keyboardType(.numberPad)
                    
                    Button("Locate on Map") {
                        viewModel.geocodeAddress()
                    }
                    
                    Map(coordinateRegion: $viewModel.region, interactionModes: .all)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .overlay(Image(systemName: "mappin").foregroundColor(.red).font(.largeTitle).padding(.bottom, 20))
                }
                
                Section(header: Text("Preferences")) {
                    Picker("Tenants", selection: $viewModel.allowedTenants) {
                        ForEach(AllowedTenants.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    DatePicker("Available From", selection: $viewModel.availableDate, displayedComponents: .date)
                }
                
                Section(header: Text("Property Images")) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("Select Images", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImagesData, id: \.self) { data in
                                if let img = UIImage(data: data) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
                .onChange(of: selectedItems) { newItems in
                    Task {
                        selectedImagesData = []
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                selectedImagesData.append(data)
                            }
                        }
                    }
                }
                
                if let error = viewModel.errorMsg {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") { viewModel.submit(imagesData: selectedImagesData) }
                    .disabled(viewModel.isSubmitting)
                }
            }
            .onChange(of: viewModel.shouldDismiss) { val in
                if val { dismiss() }
            }
        }
    }
}

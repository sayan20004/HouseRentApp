//
//  AddPropertyView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import SwiftUI
import Combine

class AddPropertyViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var propertyType = PropertyType.apartment
    @Published var bhk = 1
    @Published var furnishing = Furnishing.unfurnished
    @Published var rent = ""
    @Published var deposit = ""
    @Published var area = ""
    @Published var city = ""
    @Published var locationArea = ""
    @Published var pincode = ""
    @Published var allowedTenants = AllowedTenants.any
    @Published var availableDate = Date()
    @Published var imageUrls = ""
    
    @Published var isSubmitting = false
    @Published var shouldDismiss = false
    @Published var errorMsg: String?
    
    func submit() {
        guard let rentInt = Int(rent),
              let depositInt = Int(deposit),
              let areaInt = Int(area) else { return }
        
        let images = imageUrls.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        let location = Location(city: city, area: locationArea, landmark: nil, pincode: pincode)
        
        let input = PropertyInput(
            title: title,
            description: description,
            propertyType: propertyType.rawValue,
            bhk: bhk,
            furnishing: furnishing.rawValue,
            rent: rentInt,
            securityDeposit: depositInt,
            builtUpArea: areaInt,
            availableFrom: ISO8601DateFormatter().string(from: availableDate),
            location: location,
            amenities: [],
            images: images,
            allowedTenants: allowedTenants.rawValue
        )
        
        isSubmitting = true
        Task {
            do {
                try await PropertyService.shared.createProperty(input)
                await MainActor.run { shouldDismiss = true }
            } catch {
                await MainActor.run { errorMsg = error.localizedDescription }
            }
            await MainActor.run { isSubmitting = false }
        }
    }
}

struct AddPropertyView: View {
    @StateObject private var viewModel = AddPropertyViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Details")) {
                    TextField("Title", text: $viewModel.title)
                    TextField("Description", text: $viewModel.description)
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
                    TextField("Area (sqft)", text: $viewModel.area).keyboardType(.numberPad)
                    Picker("Furnishing", selection: $viewModel.furnishing) {
                        ForEach(Furnishing.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Location")) {
                    TextField("City", text: $viewModel.city)
                    TextField("Area", text: $viewModel.locationArea)
                    TextField("Pincode", text: $viewModel.pincode).keyboardType(.numberPad)
                }
                
                Section(header: Text("Preferences")) {
                    Picker("Tenants", selection: $viewModel.allowedTenants) {
                        ForEach(AllowedTenants.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    DatePicker("Available From", selection: $viewModel.availableDate, displayedComponents: .date)
                }
                
                Section(header: Text("Images")) {
                    TextField("Image URLs (comma separated)", text: $viewModel.imageUrls)
                }
                
                if let error = viewModel.errorMsg {
                    Text(error).foregroundColor(.red)
                }
                
                Button(action: viewModel.submit) {
                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Text("Post Property")
                    }
                }
            }
            .navigationTitle("Add Property")
            .onChange(of: viewModel.shouldDismiss) { val in
                if val { dismiss() }
            }
        }
    }
}

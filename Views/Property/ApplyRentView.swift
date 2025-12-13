//
//  ApplyRentView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI

struct ApplyRentView: View {
    @ObservedObject var viewModel: PropertyDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var date = Date().addingTimeInterval(86400 * 7)
    @State private var offerString = ""
    @State private var message = "I am interested in this property..."
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Move-in Date", selection: $date, in: Date()..., displayedComponents: .date)
                    TextField("Offered Monthly Rent (Optional)", text: $offerString)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Message to Owner")) {
                    TextEditor(text: $message)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Rental Application")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        let offer = Int(offerString)
                        viewModel.applyForRent(message: message, offer: offer, date: date)
                    }
                }
            }
            .onChange(of: viewModel.showSuccess) { success in
                if success { dismiss() }
            }
        }
    }
}

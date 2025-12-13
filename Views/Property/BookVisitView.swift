//
//  BookVisitView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI

struct BookVisitView: View {
    @ObservedObject var viewModel: PropertyDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var date = Date().addingTimeInterval(86400)
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When would you like to visit?")) {
                    DatePicker("Date & Time", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Notes for owner (optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                if let error = viewModel.errorMsg {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle("Schedule Visit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm") {
                        viewModel.bookVisit(date: date, notes: notes)
                    }
                    .disabled(viewModel.isSubmitting)
                }
            }
            .onChange(of: viewModel.showSuccess) { success in
                if success { dismiss() }
            }
        }
    }
}

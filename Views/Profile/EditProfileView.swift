//
//  EditProfileView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
            }
            
            Button("Save Changes") {
                save()
            }
            .disabled(isLoading)
            
            if appState.currentUser?.role == .tenant {
                Section {
                    Button("Upgrade to Owner Account") {
                        upgradeToOwner()
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            name = appState.currentUser?.name ?? ""
            phone = appState.currentUser?.phone ?? ""
        }
    }
    
    func save() {
        isLoading = true
        Task {
            do {
                let user = try await AuthService.shared.updateProfile(name: name, phone: phone)
                appState.currentUser = user
                dismiss()
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
    
    func upgradeToOwner() {
        isLoading = true
        Task {
            do {
                let user = try await AuthService.shared.convertToOwner()
                appState.currentUser = user
                dismiss()
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}

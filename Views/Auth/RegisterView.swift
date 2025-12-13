//
//  RegisterView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var role = UserRole.tenant
    @State private var isLoading = false
    @State private var errorMsg: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                
                Picker("Role", selection: $role) {
                    Text("Tenant").tag(UserRole.tenant)
                    Text("Owner").tag(UserRole.owner)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)
                
                VStack(spacing: 16) {
                    TextField("Full Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    TextField("Phone", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if let error = errorMsg {
                    Text(error)
                        .foregroundColor(.error)
                        .font(.caption)
                }
                
                PrimaryButton(title: "Register", action: register, isLoading: isLoading)
            }
            .padding()
        }
        .background(Color.appBackground)
    }
    
    func register() {
        isLoading = true
        errorMsg = nil
        Task {
            do {
                let user = try await AuthService.shared.register(
                    name: name,
                    email: email,
                    phone: phone,
                    password: password,
                    role: role.rawValue
                )
                appState.currentUser = user
            } catch {
                errorMsg = error.localizedDescription
            }
            isLoading = false
        }
    }
}

//
//  LoginView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMsg: String?
    @State private var showingRegister = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Text("Welcome back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if let error = errorMsg {
                    Text(error)
                        .foregroundColor(.error)
                        .font(.caption)
                }
                
                PrimaryButton(title: "Login", action: login, isLoading: isLoading)
                
                Button("Don't have an account? Sign up") {
                    showingRegister = true
                }
                .foregroundColor(.appPrimary)
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationDestination(isPresented: $showingRegister) {
                RegisterView()
            }
        }
    }
    
    func login() {
        isLoading = true
        errorMsg = nil
        Task {
            do {
                let user = try await AuthService.shared.login(email: email, password: password)
                appState.currentUser = user
            } catch {
                errorMsg = error.localizedDescription
            }
            isLoading = false
        }
    }
}

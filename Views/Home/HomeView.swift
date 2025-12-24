//
//  HomeView.swift
//  HouseRentClient
//
//  Created by Sayan Maity on 22/11/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = PropertyListViewModel()
    @EnvironmentObject var appState: AppState
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    searchBarSection
                    quickFilterSection
                    listingsSection
                }
                .padding(.bottom, 20)
            }
            .background(Color.appBackground.edgesIgnoringSafeArea(.all))
            .onAppear {
                if viewModel.properties.isEmpty {
                    viewModel.loadInitial()
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(viewModel: viewModel)
            }
            // Hide standard nav bar so we can use our custom header
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.light) // Force light mode for clean UI
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back!")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.appPrimary)
                    Text(appState.currentUser?.name ?? "User")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
            }
            Spacer()
            // Profile Image Placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search city, area...", text: $viewModel.searchText)
                    .foregroundColor(.textPrimary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            Button(action: { showingFilters.toggle() }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(14)
                    .background(Color.appPrimary)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    private var quickFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(QuickFilter.allCases) { filter in
                    Button(action: {
                        viewModel.selectQuickFilter(filter)
                    }) {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(viewModel.selectedQuickFilter == filter ? Color.appPrimary : Color.white)
                            .foregroundColor(viewModel.selectedQuickFilter == filter ? .white : .textPrimary)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: (viewModel.selectedQuickFilter == filter) ? 0 : 3, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: (viewModel.selectedQuickFilter == filter) ? 0 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4) // space for shadow
        }
    }
    
    private var listingsSection: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("Nearby Properties")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            .padding(.horizontal)
            
            // Content State Handling
            if viewModel.isLoading && viewModel.properties.isEmpty {
                LoadingView()
                    .frame(height: 200)
            } else if viewModel.properties.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.properties) { property in
                        // FIX: Wrapped Card directly in NavigationLink
                        NavigationLink(destination: PropertyDetailView(property: property)) {
                            PropertyCardView(property: property)
                        }
                        .buttonStyle(PlainButtonStyle()) // Keeps original card styling
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "house.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No properties found")
                .font(.headline)
                .foregroundColor(.textPrimary)
            Text("Try changing your filters or search term.")
                .font(.caption)
                .foregroundColor(.textSecondary)
            Button("Clear Filters") {
                viewModel.searchText = ""
                viewModel.selectQuickFilter(.all)
                viewModel.loadInitial()
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @ObservedObject var viewModel: PropertyListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget")) {
                    TextField("Min Rent", text: $viewModel.minRent)
                        .keyboardType(.numberPad)
                    TextField("Max Rent", text: $viewModel.maxRent)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Details")) {
                    Picker("Bedrooms", selection: $viewModel.selectedBHK) {
                        Text("Any").tag(nil as Int?)
                        ForEach(1...5, id: \.self) { bhk in
                            Text("\(bhk) BHK").tag(bhk as Int?)
                        }
                    }
                    
                    Picker("Property Type", selection: $viewModel.propertyType) {
                        Text("Any").tag(nil as PropertyType?)
                        ForEach(PropertyType.allCases) { type in
                            Text(type.displayName).tag(type as PropertyType?)
                        }
                    }
                    
                    Picker("Furnishing", selection: $viewModel.furnishing) {
                        Text("Any").tag(nil as Furnishing?)
                        ForEach(Furnishing.allCases) { type in
                            Text(type.displayName).tag(type as Furnishing?)
                        }
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Picker("Tenant Type", selection: $viewModel.allowedTenants) {
                        Text("Any").tag(nil as AllowedTenants?)
                        ForEach(AllowedTenants.allCases) { type in
                            Text(type.displayName).tag(type as AllowedTenants?)
                        }
                    }
                    
                    Toggle("Pets Allowed", isOn: $viewModel.petsAllowed)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.minRent = ""
                        viewModel.maxRent = ""
                        viewModel.selectedBHK = nil
                        viewModel.propertyType = nil
                        viewModel.furnishing = nil
                        viewModel.allowedTenants = nil
                        viewModel.petsAllowed = false
                        viewModel.applyFilters()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

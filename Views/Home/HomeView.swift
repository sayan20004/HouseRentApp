//
//  HomeView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = PropertyListViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Quick Search Header
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search city or area...", text: $viewModel.city)
                        .onSubmit {
                            viewModel.applyFilters()
                        }
                    
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.appPrimary)
                    }
                }
                .padding()
                .background(Color.white)
                
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.properties.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "house.slash")
                            .font(.largeTitle)
                            .padding()
                        Text("No properties found")
                        Button("Clear Filters") {
                            viewModel.city = ""
                            viewModel.selectedBHK = nil
                            viewModel.minRent = ""
                            viewModel.maxRent = ""
                            viewModel.loadInitial()
                        }
                        .padding()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.properties) { property in
                            ZStack {
                                PropertyCardView(property: property)
                                NavigationLink(destination: PropertyDetailView(property: property)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.bottom, 8)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.loadInitial()
                    }
                }
            }
            .navigationTitle("Discover")
            .background(Color.appBackground)
            .onAppear {
                if viewModel.properties.isEmpty {
                    viewModel.loadInitial()
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(viewModel: viewModel)
            }
        }
    }
}

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
                
                Section(header: Text("BHK")) {
                    Picker("Bedrooms", selection: $viewModel.selectedBHK) {
                        Text("Any").tag(nil as Int?)
                        Text("1 BHK").tag(1 as Int?)
                        Text("2 BHK").tag(2 as Int?)
                        Text("3 BHK").tag(3 as Int?)
                        Text("4+ BHK").tag(4 as Int?)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.minRent = ""
                        viewModel.maxRent = ""
                        viewModel.selectedBHK = nil
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
    }
}


#Preview("HomeView") {
    HomeView()
}

#Preview("FilterSheet - Empty Filters") {
    let vm = PropertyListViewModel()
    return FilterSheet(viewModel: vm)
}

#Preview("FilterSheet - With Values") {
    let vm = PropertyListViewModel()
    vm.minRent = "10000"
    vm.maxRent = "30000"
    vm.selectedBHK = 2
    return FilterSheet(viewModel: vm)
}

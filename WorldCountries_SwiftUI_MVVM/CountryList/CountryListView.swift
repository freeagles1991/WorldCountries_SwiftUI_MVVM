//
//  CountryListView.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 06.12.2024.
//

import SwiftUI
import CoreData

struct CountryListView: View {
    @StateObject private var viewModel: CountryListViewModel
    @State private var showFavorites = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CountryListViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                // Загрузка: таблица-заглушка
                PlaceholderView()
            } else {
                countryListView
                    .navigationTitle("Countries")
                    .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.filterCountries()
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showFavorites = true
                            }) {
                                Image(systemName: "star.fill")
                            }
                        }
                    }
                    .sheet(isPresented: $showFavorites, onDismiss: {
                        viewModel.fetchCountries()
                    }) {
                        FavoritesView(context: viewModel.context)
                    }
            }
        }
        .alert("Ошибка", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var countryListView: some View {
        List(viewModel.filteredCountries) { country in
            NavigationLink(destination: CountryDetailView(context: viewModel.context, countryEntity: country)) {
                HStack {
                    Text(country.flag ?? "")
                        .font(.system(size: 40))
                    VStack(alignment: .leading) {
                        Text(country.name ?? "Unknown Country")
                        Text(country.region ?? "")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
}

/// Представление-заглушка с анимацией
struct PlaceholderView: View {
    @State private var isAnimating = false
    
    var body: some View {
        List(0..<10, id: \.self) { _ in
            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.gray.opacity(isAnimating ? 0.5 : 0.2))
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(height: 20)
                        .foregroundStyle(.gray.opacity(isAnimating ? 0.5 : 0.2))
                    RoundedRectangle(cornerRadius: 5)
                        .frame(height: 20)
                        .foregroundStyle(.gray.opacity(isAnimating ? 0.5 : 0.2))
                }
            }
            .padding(.vertical, 5)
        }
        .onAppear {
            DispatchQueue.main.async {
                isAnimating = true
            }
        }
        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
    }
}

#Preview {
    CountryListView(context: PersistenceController.preview.container.viewContext)
}




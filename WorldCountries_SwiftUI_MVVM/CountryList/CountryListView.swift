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

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CountryListViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                // Загрузка: таблица-заглушка
                PlaceholderView()
            } else {
                // Отображение реальных данных
                List(viewModel.countries) { country in
                    
                    NavigationLink(destination: CountryDetailView(countryDetailingEntity: country.countryDetailingEntityRel)) {
                        HStack {
                            Text(country.flag ?? "")
                                .font(.system(size: 40))
                            VStack(alignment: .leading) {
                                Text(country.name ?? "Unknown Country")
                                Text(country.region ?? "")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Countries")
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

struct CountryDetailView: View {
    var countryDetailingEntity: CountryDetailingEntity?
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(countryDetailingEntity?.officialName ?? "Unknown Country")
                .font(.largeTitle)
                .bold()
            Text("Capital: \(countryDetailingEntity?.capital ?? "Unknown Capital")")
            Text("Population: \(countryDetailingEntity?.population)")
            Text("Area: \(countryDetailingEntity?.area ?? 0.0, specifier: "%.2f") km²")
            Text("Currency: \(countryDetailingEntity?.currency ?? "")")
            Text("Languages: \(countryDetailingEntity?.languages ?? "")")
            Text("Timezones: \(countryDetailingEntity?.timezones ?? "")")
            Text("Latitude: \(countryDetailingEntity?.latitude)")
            Text("Longitude: \(countryDetailingEntity?.longitude)")
            Spacer()
        }
        .padding()
        .navigationTitle(countryDetailingEntity?.officialName ?? "Details")
    }
}


#Preview {
    CountryListView(context: PersistenceController.preview.container.viewContext)
}

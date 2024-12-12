//
//  CountryListView.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 06.12.2024.
//

import SwiftUI
import CoreData
import Kingfisher

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
                    
                    NavigationLink(destination: CountryDetailView(countryEntity: country)) {
                        HStack {
                            Text(country.flag ?? "")
                                .font(.system(size: 40))
                            VStack(alignment: .leading) {
                                Text(country.name ?? "Unknown Country")
                                Text(country.region ?? "")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: country.isFavorite ? "star.fill" : "star")
                                .foregroundColor(country.isFavorite ? .yellow : .gray)
                                .onTapGesture {
                                    viewModel.toggleFavorite(for: country)
                                }
                        }
                    }
                }
                .navigationTitle("Countries")
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
    var countryEntity: CountryEntity?
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            CountryFlagView(imageURL: countryEntity?.countryDetailingEntityRel?.flagImage)
            Text(countryEntity?.countryDetailingEntityRel?.officialName ?? "Unknown Country")
                .font(.largeTitle)
                .bold()
            Text("Capital: \(countryEntity?.countryDetailingEntityRel?.capital ?? "Unknown Capital")")
            
            if let population = countryEntity?.countryDetailingEntityRel?.population {
                Text("Population: \(population)")
            } else {
                Text("Population: Unknown")
            }
            
            Text("Area: \(countryEntity?.countryDetailingEntityRel?.area ?? 0.0, specifier: "%.2f") km²")
            
            Text("Currency: \(countryEntity?.countryDetailingEntityRel?.currency ?? "Unknown")")
            
            Text("Languages: \(countryEntity?.countryDetailingEntityRel?.languages ?? "Unknown")")
            
            if let timezones = countryEntity?.countryDetailingEntityRel?.timezones {
                let timezoneList = timezones.split(separator: "|").joined(separator: ", ")
                Text("Timezones: \(timezoneList)")
            } else {
                Text("Timezones: Unknown")
            }
            
            if let latitude = countryEntity?.countryDetailingEntityRel?.latitude {
                Text("Latitude: \(latitude)")
            } else {
                Text("Latitude: Unknown")
            }
            
            if let longitude = countryEntity?.countryDetailingEntityRel?.longitude {
                Text("Longitude: \(longitude)")
            } else {
                Text("Longitude: Unknown")
            }
            
            Spacer()
        }
        .padding()
    }
}

struct CountryFlagView: View {
    let imageURL: String?
    
    var body: some View {
        GeometryReader { geometry in
            KFImage(URL(string: imageURL ?? ""))
                .placeholder {
                    // Заглушка
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .cancelOnDisappear(true)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.width * 0.6) // Пропорции 16:9
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2) // Обводка
                )
                .clipped()
        }
        .frame(height: UIScreen.main.bounds.width * 0.6) // Ограничение высоты
    }
}


#Preview {
    CountryListView(context: PersistenceController.preview.container.viewContext)
}

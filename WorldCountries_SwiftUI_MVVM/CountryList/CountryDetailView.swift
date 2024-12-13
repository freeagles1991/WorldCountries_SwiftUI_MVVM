//
//  CountryDetailView.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 12.12.2024.
//

import SwiftUI
import Kingfisher
import MapKit
import CoreData

struct CountryDetailView: View {
    @StateObject private var viewModel: CountryDetailViewModel
    @ObservedObject var countryEntity: CountryEntity
    
    init(context: NSManagedObjectContext, countryEntity: CountryEntity) {
        _viewModel = StateObject(wrappedValue: CountryDetailViewModel(context: context))
        self.countryEntity = countryEntity
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CountryFlagView(imageURL: countryEntity.countryDetailingEntityRel?.flagImage)
                
                HStack(alignment: .top, spacing: 8) {
                    Text(countryEntity.countryDetailingEntityRel?.officialName ?? "Unknown Country")
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(nil) // Позволяет тексту переноситься на несколько строк
                    Spacer()
                    VStack {
                        Button(action: {
                            viewModel.toggleFavorite(for: countryEntity)
                        }) {
                            Image(systemName: countryEntity.isFavorite ? "star.fill" : "star")
                                .foregroundColor(countryEntity.isFavorite ? .yellow : .gray)
                                .font(.largeTitle)
                        }
                        .frame(maxWidth: 50.0, alignment: .center)
                    }
                }
                
                Text("Capital: \(countryEntity.countryDetailingEntityRel?.capital ?? "Unknown Capital")")
                
                if let population = countryEntity.countryDetailingEntityRel?.population {
                    Text("Population: \(population)")
                } else {
                    Text("Population: Unknown")
                }
                
                Text("Area: \(countryEntity.countryDetailingEntityRel?.area ?? 0.0, specifier: "%.2f") km²")
                
                if let currency = countryEntity.countryDetailingEntityRel?.currency {
                    let currencyList = currency.split(separator: "|").map { String($0) }
                    HStack {
                        Text("Currency: ")
                        StringChipView(items: currencyList, backgroundColor: .green)
                    }
                } else {
                    Text("Currency: Unknown")
                }
                
                if let languages = countryEntity.countryDetailingEntityRel?.languages {
                    let languageList = languages.split(separator: "|").map { String($0) }
                    HStack {
                        Text("Languages: ")
                        StringChipView(items: languageList, backgroundColor: .yellow)
                    }
                } else {
                    Text("Languages: Unknown")
                }
                
                if let timezones = countryEntity.countryDetailingEntityRel?.timezones {
                    let timezoneList = timezones.split(separator: "|").map { String($0) }
                    HStack {
                        Text("Timezones: ")
                        StringChipView(items: timezoneList, backgroundColor: .blue)
                    }
                } else {
                    Text("Timezones: Unknown")
                }
                
                if let latitude = countryEntity.countryDetailingEntityRel?.latitude,
                   let longitude = countryEntity.countryDetailingEntityRel?.longitude {
                    Map {
                        Marker(
                            "Capital: \(countryEntity.countryDetailingEntityRel?.capital ?? "Unknown")",
                            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        )
                    }
                    .mapStyle(.standard)
                    .frame(height: 300)
                    .cornerRadius(10)
                } else {
                    Text("Location: Unknown")
                }
            }
            .padding()
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

struct StringChipView: View {
    let items: [String]
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                    .background(backgroundColor.opacity(0.2))
                    .cornerRadius(20)
                    .shadow(radius: 2)
            }
        }
    }
}

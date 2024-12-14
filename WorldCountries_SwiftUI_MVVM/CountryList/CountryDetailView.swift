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
    @EnvironmentObject var languageManager: LanguageManager
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
                    Text(countryOfficialName(for: countryEntity))
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(nil)
                    Spacer()
                    Button(action: {
                        viewModel.toggleFavorite(for: countryEntity)
                    }) {
                        Image(systemName: countryEntity.isFavorite ? Constants.Images.favoriteFilled : Constants.Images.favoriteEmpty)
                            .foregroundColor(countryEntity.isFavorite ? .yellow : .gray)
                            .font(.largeTitle)
                    }
                }
                
                Text("\(Constants.Text.capital): \(countryEntity.countryDetailingEntityRel?.capital ?? Constants.Text.unknown)")
                
                if let population = countryEntity.countryDetailingEntityRel?.population {
                    Text("\(Constants.Text.population)\(population)")
                } else {
                    Text("\(Constants.Text.population)\(Constants.Text.unknown)")
                }
                
                if let area = countryEntity.countryDetailingEntityRel?.area {
                    Text("\(Constants.Text.area)\(area, specifier: "%.2f") km²")
                } else {
                    Text("\(Constants.Text.area)\(Constants.Text.unknown)")
                }
                
                if let currency = countryEntity.countryDetailingEntityRel?.currency {
                    let currencyList = currency.split(separator: "|").map { String($0) }
                    HStack {
                        Text(Constants.Text.currency)
                        StringChipView(items: currencyList, backgroundColor: .green)
                    }
                } else {
                    Text("\(Constants.Text.currency)\(Constants.Text.unknown)")
                }
                
                if let languages = countryEntity.countryDetailingEntityRel?.languages {
                    let languageList = languages.split(separator: "|").map { String($0) }
                    HStack {
                        Text(Constants.Text.languages)
                        StringChipView(items: languageList, backgroundColor: .yellow)
                    }
                } else {
                    Text("\(Constants.Text.languages)\(Constants.Text.unknown)")
                }
                
                if let timezones = countryEntity.countryDetailingEntityRel?.timezones {
                    let timezoneList = timezones.split(separator: "|").map { String($0) }
                    HStack {
                        Text(Constants.Text.timezones)
                        StringChipView(items: timezoneList, backgroundColor: .blue)
                    }
                } else {
                    Text("\(Constants.Text.timezones)\(Constants.Text.unknown)")
                }
                
                if let latitude = countryEntity.countryDetailingEntityRel?.latitude,
                   let longitude = countryEntity.countryDetailingEntityRel?.longitude {
                    Map {
                        Marker(
                            "\(Constants.Text.capital) \(countryEntity.countryDetailingEntityRel?.capital ?? Constants.Text.unknown)",
                            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        )
                    }
                    .mapStyle(.standard)
                    .frame(height: 300)
                    .cornerRadius(10)
                } else {
                    Text("\(Constants.Text.location)\(Constants.Text.unknown)")
                }
            }
            .padding()
        }
        .alert(Constants.Text.errorTitle, isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button(Constants.Text.errorMessageOK, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private func countryOfficialName(for country: CountryEntity) -> String {
        switch languageManager.currentLanguage {
        case "ru":
            return country.countryTranslationEntityRel?.ruOfficial ?? Constants.Text.unknownCountry
        default:
            return country.countryDetailingEntityRel?.officialName ?? Constants.Text.unknownCountry
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
                            Image(systemName: Constants.Images.placeholder)
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

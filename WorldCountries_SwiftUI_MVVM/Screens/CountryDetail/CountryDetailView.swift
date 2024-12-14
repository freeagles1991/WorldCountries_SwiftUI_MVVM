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
    @ObservedObject var country: CountryEntity
    
    init(context: NSManagedObjectContext, country: CountryEntity) {
        _viewModel = StateObject(wrappedValue: CountryDetailViewModel(context: context))
        self.country = country
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CountryFlagView(imageURL: country.countryDetailingEntityRel?.flagImage)
                
                HStack(alignment: .top, spacing: 8) {
                    Text(languageManager.countryOfficialName(for: country))
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(nil)
                    Spacer()
                    Button(action: {
                        viewModel.toggleFavorite(for: country)
                    }) {
                        Image(systemName: country.isFavorite ? Constants.Images.favoriteFilled : Constants.Images.favoriteEmpty)
                            .foregroundColor(country.isFavorite ? .yellow : .gray)
                            .font(.largeTitle)
                    }
                }
                
                Text("\(Constants.Text.capital): \(country.countryDetailingEntityRel?.capital ?? Constants.Text.unknown)")
                
                if let population = country.countryDetailingEntityRel?.population {
                    Text("\(Constants.Text.population)\(population)")
                } else {
                    Text("\(Constants.Text.population)\(Constants.Text.unknown)")
                }
                
                if let area = country.countryDetailingEntityRel?.area {
                    Text("\(Constants.Text.area)\(area, specifier: "%.2f") km²")
                } else {
                    Text("\(Constants.Text.area)\(Constants.Text.unknown)")
                }
                
                if let currency = country.countryDetailingEntityRel?.currency {
                    let currencyList = currency.split(separator: "|").map { String($0) }
                    HStack {
                        Text(Constants.Text.currency)
                        StringChipView(items: currencyList, backgroundColor: .green)
                    }
                } else {
                    Text("\(Constants.Text.currency)\(Constants.Text.unknown)")
                }
                
                if let languages = country.countryDetailingEntityRel?.languages {
                    let languageList = languages.split(separator: "|").map { String($0) }
                    HStack {
                        Text(Constants.Text.languages)
                        StringChipView(items: languageList, backgroundColor: .yellow)
                    }
                } else {
                    Text("\(Constants.Text.languages)\(Constants.Text.unknown)")
                }
                
                if let timezones = country.countryDetailingEntityRel?.timezones {
                    let timezoneList = timezones.split(separator: "|").map { String($0) }
                    HStack {
                        Text(Constants.Text.timezones)
                        StringChipView(items: timezoneList, backgroundColor: .blue)
                    }
                } else {
                    Text("\(Constants.Text.timezones)\(Constants.Text.unknown)")
                }
                
                if let latitude = country.countryDetailingEntityRel?.latitude,
                   let longitude = country.countryDetailingEntityRel?.longitude {
                    Map {
                        Marker(
                            "\(Constants.Text.capital) \(country.countryDetailingEntityRel?.capital ?? Constants.Text.unknown)",
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let countryName = country.name,
                   let capital = country.countryDetailingEntityRel?.capital,
                   let population = country.countryDetailingEntityRel?.population,
                   let area = country.countryDetailingEntityRel?.area,
                   let currency = country.countryDetailingEntityRel?.currency,
                   let languages = country.countryDetailingEntityRel?.languages,
                   let timezones = country.countryDetailingEntityRel?.timezones {
                    ShareLink(
                        item: shareText(
                            for: countryName,
                            capital: capital,
                            population: population,
                            area: area,
                            currency: currency,
                            languages: languages,
                            timezones: timezones
                        )
                    ) {
                        Image(systemName: Constants.Images.share)
                    }
                }
            }
        }
    }
    
    private func shareText(for countryName: String, capital: String, population: Int64?, area: Double?, currency: String?, languages: String?, timezones: String?) -> String {
        var shareMessage = """
        \(Constants.Text.country): \(countryName)
        \(Constants.Text.capital): \(capital)
        """
        
        if let population = population {
            shareMessage += "\n\(Constants.Text.population)\(population)"
        }
        
        if let area = area {
            shareMessage += "\n\(Constants.Text.area)\(String(format: "%.2f", area)) km²"
        }
        
        if let currency = currency {
            let currencyList = currency.split(separator: "|").joined(separator: ", ")
            shareMessage += "\n\(Constants.Text.currency)\(currencyList)"
        }
        
        if let languages = languages {
            let languageList = languages.split(separator: "|").joined(separator: ", ")
            shareMessage += "\n\(Constants.Text.languages)\(languageList)"
        }
        
        if let timezones = timezones {
            let timezoneList = timezones.split(separator: "|").joined(separator: ", ")
            shareMessage += "\n\(Constants.Text.timezones)\(timezoneList)"
        }
        
        return shareMessage
    }
}

struct CountryFlagView: View {
    let imageURL: String?
    
    var body: some View {
        GeometryReader { geometry in
            KFImage(URL(string: imageURL ?? ""))
                .placeholder {
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
                .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .clipped()
        }
        .frame(height: UIScreen.main.bounds.width * 0.6)
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

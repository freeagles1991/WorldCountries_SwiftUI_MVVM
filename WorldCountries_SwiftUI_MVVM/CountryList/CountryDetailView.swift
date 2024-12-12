//
//  CountryDetailView.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 12.12.2024.
//

import SwiftUI
import Kingfisher

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

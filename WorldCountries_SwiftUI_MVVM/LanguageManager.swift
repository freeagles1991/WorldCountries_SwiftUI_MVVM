//
//  LanguageManager.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 13.12.2024.
//

import SwiftUI
import Foundation

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String

    init() {
        let systemLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        currentLanguage = ["ru", "en"].contains(systemLanguage) ? String(systemLanguage) : "en"
    }
    
    func countryOfficialName(for country: CountryEntity) -> String {
        switch currentLanguage {
        case "ru":
            return country.countryTranslationEntityRel?.ruOfficial ?? Constants.Text.unknownCountry
        default:
            return country.countryDetailingEntityRel?.officialName ?? Constants.Text.unknownCountry
        }
    }
    
    func countryCommonName(for country: CountryEntity) -> String {
        switch currentLanguage {
        case "ru":
            return country.countryTranslationEntityRel?.ruCommon ?? Constants.Text.unknownCountry
        default:
            return country.name ?? Constants.Text.unknownCountry
        }
    }
    
}


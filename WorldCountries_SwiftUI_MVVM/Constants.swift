//
//  Constants.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 13.12.2024.
//

import Foundation

enum Constants {
    enum Text {
        static var unknown: String { String(localized: "unknown") }
        static var country: String { String(localized: "country") }
        static var capital: String { String(localized: "capital") }
        static var population: String { String(localized: "population") }
        static var area: String { String(localized: "area") }
        static var currency: String { String(localized: "currency") }
        static var languages: String { String(localized: "languages") }
        static var timezones: String { String(localized: "timezones") }
        static var location: String { String(localized: "location") }
        static var countriesTitle: String { String(localized: "countries_title") }
        static var unknownCountry: String { String(localized: "unknown_country") }
        static var unknownRegion: String { String(localized: "unknown_region") }
        static var errorTitle: String { String(localized: "error_title") }
        static var errorMessageOK: String { String(localized: "error_message_ok") }
        static var favoritesTitle: String { String(localized: "favorites_title") }
    }
    
    enum Images {
        static let favoriteFilled = "star.fill"
        static let favoriteEmpty = "star"
        static let placeholder = "photo"
        static let removeFavorite = "xmark"
    }
    
    static var apiBaseUrl: String {
        return Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? ""
    }
}

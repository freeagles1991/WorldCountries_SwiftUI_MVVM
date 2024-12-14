//
//  LanguageManager.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 13.12.2024.
//

import SwiftUI

import Foundation

import Foundation

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String

    init() {
        let systemLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        currentLanguage = ["ru", "en"].contains(systemLanguage) ? String(systemLanguage) : "en"
    }
}


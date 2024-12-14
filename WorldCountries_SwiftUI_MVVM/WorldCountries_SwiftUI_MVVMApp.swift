//
//  WorldCountries_SwiftUI_MVVMApp.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 05.12.2024.
//

import SwiftUI

@main
struct WorldCountriesApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            CountryListView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(languageManager)
        }
    }
}

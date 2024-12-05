//
//  WorldCountries_SwiftUI_MVVMApp.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 05.12.2024.
//

import SwiftUI

@main
struct WorldCountries_SwiftUI_MVVMApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  DataSaver.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 06.12.2024.
//

import CoreData

final class DataSaver {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveCountries(_ countries: [CountryResponse]) {
        context.perform {
            for countryResponse in countries {
                let countryEntity = CountryEntity(context: self.context)
                countryEntity.id = UUID()
                countryEntity.name = countryResponse.name.common
                countryEntity.region = countryResponse.region
                countryEntity.flag = countryResponse.flag
                countryEntity.isFavorite = false
            }

            do {
                try self.context.save()
                print("Countries saved successfully.")
            } catch {
                print("Failed to save countries: \(error.localizedDescription)")
            }
        }
    }
}

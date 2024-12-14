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
                if self.doesCountryExist(name: countryResponse.name.common) {
                    print("Country \(countryResponse.name.common) already exists. Skipping.")
                    continue
                }
                
                let countryEntity = CountryEntity(context: self.context)
                countryEntity.id = UUID()
                countryEntity.name = countryResponse.name.common
                countryEntity.region = countryResponse.region
                countryEntity.flag = countryResponse.flag
                countryEntity.isFavorite = false
                
                let countryDetailingEntity = CountryDetailingEntity(context: self.context)
                countryDetailingEntity.id = countryEntity.id
                countryDetailingEntity.officialName = countryResponse.name.official
                countryDetailingEntity.capital = countryResponse.capital?.joined(separator: "|")
                countryDetailingEntity.population = Int64(countryResponse.population ?? 0)
                countryDetailingEntity.area = countryResponse.area ?? 0.0
                countryDetailingEntity.currency = countryResponse.currencies?.values
                    .map { "\($0.name ?? "") (\($0.symbol ?? ""))" }.joined(separator: "|")
                countryDetailingEntity.languages = countryResponse.languages?.values.map { $0 }.joined(separator: "|")
                countryDetailingEntity.timezones = countryResponse.timezones?.joined(separator: "|")
                countryDetailingEntity.latitude = countryResponse.capitalInfo?.latlng?[0] ?? 0.0
                countryDetailingEntity.longitude = countryResponse.capitalInfo?.latlng?[1] ?? 0.0
                countryDetailingEntity.flagImage = countryResponse.flags?.png
                
                countryEntity.countryDetailingEntityRel = countryDetailingEntity
                countryDetailingEntity.countryEntityRel = countryEntity
                
                let countryTranslationEntity = CountryTranslationEntity(context: self.context)

                if let russian = countryResponse.translations?["rus"] {
                    countryTranslationEntity.ruCommon = russian.common
                    countryTranslationEntity.ruOfficial = russian.official
                }
                
                countryTranslationEntity.contryEntityRel = countryEntity
                countryEntity.countryTranslationEntityRel = countryTranslationEntity
            }

            do {
                try self.context.save()
                print("Countries saved successfully.")
            } catch {
                print("Failed to save countries: \(error.localizedDescription)")
            }
        }
    }

    private func doesCountryExist(name: String) -> Bool {
        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        do {
            let count = try context.count(for: fetchRequest)
            print("Проверка существования страны \(name): \(count > 0 ? "существует" : "не существует")")
            return count > 0
        } catch {
            print("Ошибка проверки существования страны \(name): \(error.localizedDescription)")
            return false
        }
    }
}

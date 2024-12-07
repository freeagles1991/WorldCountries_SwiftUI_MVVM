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
                // Проверка на существование сущности с таким же именем
                if self.doesCountryExist(name: countryResponse.name.common) {
                    print("Country \(countryResponse.name.common) already exists. Skipping.")
                    continue
                }
                
                // Создание новой сущности
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
            }

            do {
                try self.context.save()
                print("Countries saved successfully.")
            } catch {
                print("Failed to save countries: \(error.localizedDescription)")
            }
        }
    }
    
    func clearAllEntities() {
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CountryEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try self.context.execute(deleteRequest)
                try self.context.save()
                print("All entities cleared successfully.")
            } catch {
                print("Failed to clear entities: \(error.localizedDescription)")
            }
        }
    }

    private func doesCountryExist(name: String) -> Bool {
        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1 // Ограничиваем запрос одной записью для оптимизации
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0 // Возвращаем true, если такая запись уже существует
        } catch {
            print("Failed to check if country exists: \(error.localizedDescription)")
            return false
        }
    }
}

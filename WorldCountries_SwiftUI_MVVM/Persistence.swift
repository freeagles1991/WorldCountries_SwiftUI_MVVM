//
//  Persistence.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 05.12.2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WorldCountries_SwiftUI_MVVM")
        
        let description = container.persistentStoreDescriptions.first
        
//        Тут очищаем хранилище
//        let url = description?.url
//        do {
//            if let url = url {
//                try FileManager.default.removeItem(at: url)
//            }
//        } catch {
//            print("Failed to delete persistent store: \(error.localizedDescription)")
//        }
        
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let exampleCountry = CountryEntity(context: context)
        exampleCountry.id = UUID()
        exampleCountry.name = "Japan"
        exampleCountry.region = "Asia"
        exampleCountry.flag = "🇯🇵"
        exampleCountry.isFavorite = false

        let exampleDetails = CountryDetailingEntity(context: context)
        exampleDetails.id = exampleCountry.id
        exampleDetails.officialName = "Japan"
        exampleDetails.capital = "Tokyo"
        exampleDetails.population = 126000000
        exampleDetails.area = 377975.0
        exampleDetails.languages = "Japanese"
        exampleDetails.timezones = "UTC+09:00"
        exampleDetails.flagImage = "https://flagcdn.com/w320/jp.png"

        exampleCountry.countryDetailingEntityRel = exampleDetails

        do {
            try context.save()
        } catch {
            fatalError("Failed to create preview data: \(error.localizedDescription)")
        }

        return controller
    }()
}

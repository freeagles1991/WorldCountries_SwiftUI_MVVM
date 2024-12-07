//
//  Persistence.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 05.12.2024.
//

import CoreData

/// Класс для управления Core Data в приложении.
struct PersistenceController {
    
    /// Singleton-экземпляр для основного контекста приложения.
    static let shared = PersistenceController()

    /// Контейнер NSPersistentContainer для управления Core Data.
    let container: NSPersistentContainer

    /// Инициализация PersistenceController.
    /// - Parameter inMemory: Указывает, нужно ли использовать временное хранилище в памяти (например, для тестов).
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WorldCountries_SwiftUI_MVVM")
        
        let description = container.persistentStoreDescriptions.first
        
        let url = description?.url
        do {
            if let url = url {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Failed to delete persistent store: \(error.localizedDescription)")
        }
        
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true

        // Настройка временного хранилища (если inMemory = true)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Загрузка персистентных хранилищ
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Обработка ошибок загрузки хранилища
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Настройка автоматического слияния изменений
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Добавляем примерные данные
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

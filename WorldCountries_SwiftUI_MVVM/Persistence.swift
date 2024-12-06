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

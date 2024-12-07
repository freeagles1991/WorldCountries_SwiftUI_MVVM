//
//  CountryListViewModel.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 07.12.2024.
//

import SwiftUI
import CoreData

final class CountryListViewModel: ObservableObject {
    @Published var isLoading: Bool = true // Состояние загрузки
    @Published var countries: [CountryEntity] = [] // Загруженные данные
    @Published var countryDetails: CountryDetailingEntity? // Детализация страны

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchCountries()
    }

    /// Проверяем Core Data и загружаем данные
    func fetchCountries() {
        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                // Если данных нет, загружаем из API
                loadFromNetwork()
            } else {
                // Если данные есть, отображаем их
                DispatchQueue.main.async {
                    self.countries = results
                    self.isLoading = false
                }
            }
        } catch {
            print("Failed to fetch countries from Core Data: \(error.localizedDescription)")
        }
    }

    /// Загрузка данных из API
    private func loadFromNetwork() {
        NetworkClient.shared.fetchCountries { result in
            switch result {
            case .success(let countries):
                let dataSaver = DataSaver(context: self.context)
                dataSaver.saveCountries(countries)
                DispatchQueue.main.async {
                    self.fetchCountries() // Повторный вызов для обновления из Core Data
                }
            case .failure(let error):
                print("Failed to fetch countries: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

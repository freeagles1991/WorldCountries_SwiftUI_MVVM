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
    @Published var errorMessage: String? // Сообщение об ошибке для отображения алерта

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
            print("Найдено стран в Core Data: \(results.count)")
            if results.isEmpty {
                print("Core Data пуста. Загружаем из сети...")
                loadFromNetwork()
            } else {
                DispatchQueue.main.async {
                    self.countries = results
                    self.isLoading = false
                    print("Данные успешно загружены из Core Data.")
                }
            }
        } catch {
            print("Ошибка при загрузке из Core Data: \(error.localizedDescription)")
            showError("Не удалось загрузить страны из Core Data: \(error.localizedDescription)")
        }
    }

    /// Загрузка данных из API
    private func loadFromNetwork() {
        NetworkClient.shared.fetchCountries { result in
            switch result {
            case .success(let countries):
                print("Данные успешно загружены из сети: \(countries.count) записей.")
                let dataSaver = DataSaver(context: self.context)
                dataSaver.saveCountries(countries)
                DispatchQueue.main.async {
                    self.fetchCountries() // Повторный вызов для проверки сохранённых данных
                }
            case .failure(let error):
                print("Ошибка загрузки данных из сети: \(error.localizedDescription)")
                self.showError("Не удалось загрузить данные из сети: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    //Переключаем параметр Избранное в контексте
    func toggleFavorite(for country: CountryEntity) {
        context.perform {
            country.isFavorite.toggle()

            do {
                try self.context.save()
                DispatchQueue.main.async {
                    self.fetchCountries() // Обновляем список после изменения
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError("Не удалось обновить статус избранного: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //Обработка ошибок сети
    private func handleNetworkError(_ error: Error) {
        let message: String
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                message = "Неверный URL. Проверьте адрес и попробуйте снова."
            case .noData:
                message = "Данные отсутствуют. Проверьте соединение с интернетом."
            }
        } else {
            message = "Произошла ошибка: \(error.localizedDescription)"
        }

        showError(message)
    }
    
    //Показываем алерт
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }
}

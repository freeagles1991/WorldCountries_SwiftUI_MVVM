//
//  CountryListViewModel.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 07.12.2024.
//

import SwiftUI
import CoreData

final class CountryListViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var countries: [CountryEntity] = []
    @Published var countryDetails: CountryDetailingEntity?
    @Published var searchText: String = ""
    @Published var filteredCountries: [CountryEntity] = []
    @Published var errorMessage: String?

    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchCountries()
    }

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
                    self.filteredCountries = results
                    self.isLoading = false
                    print("Данные успешно загружены из Core Data.")
                }
            }
        } catch {
            print("Ошибка при загрузке из Core Data: \(error.localizedDescription)")
            showError("Не удалось загрузить страны из Core Data: \(error.localizedDescription)")
        }
    }

    private func loadFromNetwork() {
        NetworkClient.shared.fetchCountries { result in
            switch result {
            case .success(let countries):
                print("Данные успешно загружены из сети: \(countries.count) записей.")
                let dataSaver = DataSaver(context: self.context)
                dataSaver.saveCountries(countries)
                DispatchQueue.main.async {
                    self.fetchCountries()
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
    
    func filterCountries() {
        if searchText.isEmpty {
            print("[Filter] Search text is empty. Showing all countries.")
            filteredCountries = countries
        } else {
            print("[Filter] Filtering countries starting with: \(searchText)")
            filteredCountries = countries.filter { country in
                guard let name = country.name else { return false }
                let isMatch = name.lowercased().hasPrefix(searchText.lowercased())
                if isMatch {
                    print("[Filter] Matched country: \(name)")
                }
                return isMatch
            }
            print("[Filter] Found \(filteredCountries.count) countries starting with '\(searchText)'.")
        }
    }
    
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
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }
}

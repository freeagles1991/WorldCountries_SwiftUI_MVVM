//
//  ContentView.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 05.12.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var shouldNavigate = false // Управляет переходом на следующий экран

    var body: some View {
        NavigationStack {
            VStack {
                Button("Load and Save Countries") {
                    loadAndSaveCountries()
                }
                List {
                    // Переход управляется состоянием
                    if shouldNavigate {
                        NavigationLink(value: "countryListView") {
                            Text("CountryListView")
                        }
                    }
                }
                .navigationTitle("Countries")
                // Определение маршрута
                .navigationDestination(for: String.self) { destination in
                    if destination == "countryListView" {
                        CountryListView()
                    }
                }
            }
        }
    }

    private func loadAndSaveCountries() {
        let dataSaver = DataSaver(context: viewContext)
        //dataSaver.clearAllEntities() //Удаляем все данные
        
        // Проверяем, есть ли уже данные в Core Data
        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        fetchRequest.fetchLimit = 1 // Ограничиваем запрос одним объектом для проверки наличия данных
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            if count > 0 {
                print("Data already exists in Core Data. Skipping network fetch.")
                shouldNavigate = true // Активируем переход
                return
            }
        } catch {
            print("Failed to fetch data from Core Data: \(error.localizedDescription)")
        }
        
        // Если данных нет, загружаем их из сети
        NetworkClient.shared.fetchCountries { result in
            switch result {
            case .success(let countries):
                dataSaver.saveCountries(countries)
                DispatchQueue.main.async {
                    shouldNavigate = true // Активируем переход
                }
            case .failure(let error):
                print("Failed to fetch countries: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}

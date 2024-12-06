//
//  ContentView.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 05.12.2024.
//

import SwiftUI

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
        NetworkClient.shared.fetchCountries { result in
            switch result {
            case .success(let countries):
                let dataSaver = DataSaver(context: viewContext)
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

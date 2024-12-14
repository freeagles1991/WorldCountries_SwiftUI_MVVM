//
//  CountryDetailViewModel.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 13.12.2024.
//

import SwiftUI
import CoreData

final class CountryDetailViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func toggleFavorite(for country: CountryEntity) {
        context.perform {
            country.isFavorite.toggle()

            do {
                try self.context.save()
            } catch {
                DispatchQueue.main.async {
                    self.showError("Не удалось обновить статус избранного: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }
}


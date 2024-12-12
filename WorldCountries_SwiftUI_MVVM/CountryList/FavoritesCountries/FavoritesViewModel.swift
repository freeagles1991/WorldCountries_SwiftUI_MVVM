//
//  FavoritesViewModel.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 12.12.2024.
//

import SwiftUI
import CoreData

final class FavoritesViewModel: ObservableObject {
    @Published var favoriteCountries: [CountryEntity] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchFavorites()
    }

    func fetchFavorites() {
        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isFavorite == true")

        do {
            let results = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.favoriteCountries = results
            }
        } catch {
            print("Failed to fetch favorite countries: \(error.localizedDescription)")
        }
    }

    func toggleFavorite(for country: CountryEntity) {
        context.perform {
            country.isFavorite.toggle()

            do {
                try self.context.save()
                DispatchQueue.main.async {
                    self.fetchFavorites()
                }
            } catch {
                print("Failed to update favorite status: \(error.localizedDescription)")
            }
        }
    }
}

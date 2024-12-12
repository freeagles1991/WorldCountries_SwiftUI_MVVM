//
//  FavoritesCountriesView.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 12.12.2024.
//

import SwiftUI
import CoreData

struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: FavoritesViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            List(viewModel.favoriteCountries) { country in
                HStack {
                    Text(country.flag ?? "")
                        .font(.system(size: 40))
                    VStack(alignment: .leading) {
                        Text(country.name ?? "Unknown Country")
                        Text(country.region ?? "")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: country.isFavorite ? "xmark" : "star")
                        .foregroundColor(country.isFavorite ? .red : .gray)
                        .onTapGesture {
                            viewModel.toggleFavorite(for: country)
                        }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

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
                        Text(country.name ?? Constants.Text.unknownCountry)
                        Text(country.region ?? Constants.Text.unknownRegion)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: Constants.Images.removeFavorite)
                        .foregroundColor(.red)
                        .onTapGesture {
                            viewModel.toggleFavorite(for: country)
                        }
                }
            }
            .navigationTitle(Constants.Text.favoritesTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

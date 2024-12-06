//
//  CountryListView.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 06.12.2024.
//

import SwiftUI

struct CountryListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CountryEntity.name, ascending: true)],
        animation: .default)
    private var countries: FetchedResults<CountryEntity>

    var body: some View {
        List {
            ForEach(countries) { country in
                VStack {
                    Text(country.name ?? "Unknown")
                    Text(country.region ?? "")
                    Text(country.flag ?? "")
                }
            }
        }
    }
}

#Preview {
    CountryListView()
}

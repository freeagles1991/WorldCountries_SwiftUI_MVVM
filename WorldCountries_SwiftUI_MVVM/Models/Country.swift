//
//  Country.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 06.12.2024.
//
import Foundation
import CoreData

struct Name: Decodable {
    let common: String
    let official: String
}

struct Currency: Decodable {
    let name: String?
    let symbol: String?
}

struct CapitalInfo: Decodable {
    let latlng: [Double]?
}

struct Flags: Decodable {
    let png: String?
    let svg: String?
}

struct CountryResponse: Decodable {
    let name: Name
    let region: String?
    let capital: [String]?
    let population: Int?
    let area: Double?
    let currencies: [String: Currency]?
    let languages: [String: String]?
    let timezones: [String]?
    let capitalInfo: CapitalInfo?
    let flag: String?
    let flags: Flags?
}

extension CountryResponse {
    func toCountry() -> Country {
        return Country(
            id: UUID(),
            name: self.name.common,
            region: self.region ?? "",
            flag: self.flag ?? "",
            isFavorite: false)
    }
}

struct Country {
    let id: UUID
    let name: String
    let region: String
    let flag: String
    let isFavorite: Bool
}

extension Country {
    func toCountryEntity(context: NSManagedObjectContext) -> CountryEntity {
        let entity = CountryEntity(context: context)
        entity.id = self.id
        entity.name = self.name
        entity.region = self.region
        entity.flag = self.flag
        entity.isFavorite = self.isFavorite
        return entity
    }
}


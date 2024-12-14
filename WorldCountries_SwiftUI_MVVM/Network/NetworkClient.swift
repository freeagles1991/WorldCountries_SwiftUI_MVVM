//
//  NetworkClient.swift
//  WorldCountries_SwiftUI_MVVM
//
//  Created by Дима on 06.12.2024.
//

import Foundation

final class NetworkClient {
    static let shared = NetworkClient()

    func fetchCountries(completion: @escaping (Result<[CountryResponse], Error>) -> Void) {
        let urlString = Constants.apiBaseUrl
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let countries = try JSONDecoder().decode([CountryResponse].self, from: data)
                completion(.success(countries))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}

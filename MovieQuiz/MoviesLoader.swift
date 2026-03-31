//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 23.03.2026.
//

import Foundation

// Преобразование загруженных из сервера данных в модель данных
struct MoviesLoader: MoviesLoading {
    
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    //MARK: - method Decode
    enum MoviesLoaderError: Error {
        case apiError(String)
        case noData
        case decodingError(Error)
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data): // данные пришли
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data) // десериализация фильма
                    // проверка ошибки от API
                    if !mostPopularMovies.errorMessage.isEmpty {
                        print("⁉️ Ошибка API: \(mostPopularMovies.errorMessage)")
                        handler(.failure(MoviesLoaderError.apiError(mostPopularMovies.errorMessage)))
                        return
                    }
                    
                    // проверка пустого массива
                    if mostPopularMovies.items.isEmpty {
                        print("⁉️ Отсутствуют данные для отображения: \(mostPopularMovies.items.count)")
                        handler(.failure(MoviesLoaderError.noData))
                        return
                    }
                    
                    print(" ✅ loadMovies вызван, загружено \(mostPopularMovies.items.count) фильмов")
                    handler(.success(mostPopularMovies))
                } catch {
                    print("⁉️ Ошибка парсинга данных: \(error)")
                    handler(.failure(MoviesLoaderError.decodingError(error)))
                }
            case .failure(let error): // данные не пришли
                print("⁉️ Ошибка сети: \(error)")
                handler(.failure(error))
            }
        }
    }
}


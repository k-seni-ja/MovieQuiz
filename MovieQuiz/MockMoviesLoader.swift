//
//  MockMoviesLoader.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//

import Foundation

struct MockMoviesLoader: MoviesLoading {
    
    enum MockError: Error {
        case noData
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        // возвращаем mock - data
        if let movies = MockData.mostPopularMovies {
            handler(.success(movies))
        } else {
            //не загрузились mock - data
            handler(.failure(MockError.noData))
        }
    }
}

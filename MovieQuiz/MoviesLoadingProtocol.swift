//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

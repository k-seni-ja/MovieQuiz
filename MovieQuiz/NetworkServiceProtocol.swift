//
//  NetworkRoutingProtocol.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

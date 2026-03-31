//
//  StubNetworkClient.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//

import Foundation
struct StubNetworkClient: NetworkRouting {
    let emulateError: Bool // заглушка эмулирует либо ошибку сети, либо успешный ответ
    
    enum TestError: Error { // тестовая ошибка
    case test
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
    
    // тестовый ответ от сервера в формате Data
    private var expectedResponse: Data {
        MockData.jsonString.data(using: .utf8) ?? Data()
    }
}

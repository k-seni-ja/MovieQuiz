//
//  StubNetworkClient.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//

import Foundation

struct StubNetworkClientMock: NetworkServiceProtocol {
    private let emulateError: Bool // заглушка эмулирует либо ошибку сети, либо успешный ответ
    
    // тестовый ответ от сервера
    private var expectedResponse: Data {
        MockData.jsonString.data(using: .utf8) ?? Data()
    }
    
    enum TestError: Error {
        case test
    }
    
    init(emulateError: Bool) {
        self.emulateError = emulateError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
}

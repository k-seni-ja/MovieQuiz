//
//  MoviesLoaderTest.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//
import XCTest
@testable import MovieQuiz

// MARK: - MoviesLoaderTest
class MoviesLoaderTest: XCTestCase {
    
    // MARK: - Tests
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClientMock(emulateError: false) // эмулируем успешный ответ от сети
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Ожидаем загрузку")
        loader.loadMovies { result in
            
            // Then
            switch result {
            case .success(let mostPopularMovies):
                // проверка, что фильмы загрузились (в тестовых данных всего 22шт)
                XCTAssertEqual(mostPopularMovies.items.count, 22)
                expectation.fulfill()
            case .failure(_):
                // мы не ожидаем, что пришла ошибка; если она появится, надо будет провалить тест
                XCTFail("Неожиданный сбой")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClientMock(emulateError: true) // эмулируем ошибку сети
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Ожидаем загрузку")
        loader.loadMovies { result in
            
            // Then
            switch result {
                //не ожидаем данных, если они появятся надо провалить тест
            case .success(_):
                XCTFail("Неожиданный сбой")
                //проверка, что пришла ошибка
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}

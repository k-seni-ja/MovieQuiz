//
//  MoviesLoaderTest.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//
import XCTest
@testable import MovieQuiz // импортируем наше приложение для тестирования

class MoviesLoaderTest: XCTestCase {
    
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false) // эмулируем успешный ответ от сети
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        // так как функция загрузки фильмов — асинхронная, нужно ожидание
        let expectation = expectation(description: "Ожидаем загрузку")
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let mostPopularMovies):
                // проверка, что фильмы загрузились (в тестовых данных всего 2шт)
                XCTAssertEqual(mostPopularMovies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                // мы не ожидаем, что пришла ошибка; если она появится, надо будет провалить тест
                XCTFail("Неожиданный сбой") // эта функция проваливает тест
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true) // эмулируем ошибку сети
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        // так как функция загрузки фильмов — асинхронная, нужно ожидание
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

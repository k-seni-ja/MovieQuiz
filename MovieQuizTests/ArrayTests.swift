//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//

import XCTest
@testable import MovieQuiz // импортируем наше приложение для тестирования

// MARK: - ArrayTests
class ArrayTests: XCTestCase {
    
    // MARK: - Tests
    func testSafeSubscript_returnsValue_whenIndexInRange() { // тест на успешное взятие элемента по индексу
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 0]
        // Then
        XCTAssertEqual(value, 1)
        XCTAssertNotNil(value)
    }
    
    func testSafeSubscript_returnsNil_whenIndexOutOfRange() { // тест на взятие элемента по неправильному индексу
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 14]
        // Then
        XCTAssertNil(value)
    }
}

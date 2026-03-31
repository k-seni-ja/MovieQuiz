//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//

import XCTest
@testable import MovieQuiz // импортируем наше приложение для тестирования

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws { // тест на успешное взятие элемента по индексу
       // Given
        let array = [1, 1, 2, 3, 5]
       // When
        let value = array[safe: 0]
       // Then
        XCTAssertEqual(value, 1)
        XCTAssertNotNil(value)
    }
    
    func testGetValueOutOfRange() throws { // тест на взятие элемента по неправильному индексу
        // Given
        let array = [1, 1, 2, 3, 5]
       // When
        let value = array[safe: 14]
       // Then
        XCTAssertNil(value)
    }
}

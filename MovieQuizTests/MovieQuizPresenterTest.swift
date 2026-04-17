//
//  MovieQuizPresenterTest.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 13.04.2026.
//

import XCTest
@testable import MovieQuiz

// MARK: - MovieQuizPresenterTests
final class MovieQuizPresenterTests: XCTestCase {
    
    // MARK: - Tests
    func testPresenterConvertModel() throws {
        //Given
        // создадим экземпляр MovieQuizPresenter c мок-данными (заглушка)
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        // создание тестовых данных
        let emptyData = Data()
        let question = QuizQuestion(
            imageData: emptyData,
            textQuestion: "Question Text",
            correctAnswer: true)
        
        //When
        let viewModel = presenter.convert(model: question)
        
        // Then
        XCTAssertEqual(viewModel.posterImage, emptyData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
    
    func testRestartGameResetsState() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        presenter.currentQuestionIndex = 5
        presenter.correctAnswers = 3
        
        //When
        presenter.restartGame()
        
        //Then
        XCTAssertEqual(presenter.correctAnswers, 0)
        XCTAssertEqual(presenter.currentQuestionIndex, 0)
        
    }
}



//
//  MovieQuizPresenterTest.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 13.04.2026.
//

import XCTest
@testable import MovieQuiz // импортируем наше приложение для тестирования

// MARK: - Mock class для реализации протокола
// метод convert класса MovieQuizPresenter зависит от класса MovieQuizViewController
// создаем фиктивный ViewController, который реализует протокол

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func showQuestion(quiz step: QuizStepViewModel) {}
    func showGameResult(quiz result: QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}


final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        //Given
        // создадим экземпляр MovieQuizPresenter c мок-данными (заглушка)
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        // создание тестовых данных
        let emptyData = Data() // пустая картинка
        let question = QuizQuestion(
            imageData: emptyData,
            textQuestion: "Question Text",
            correctAnswer: true)
        
        
        //When, вызов тестируемого метода
        // test convert() конвертируем модель данных QuizQuestion в QuizStepViewModel
        let viewModel = presenter.convert(model: question)
        
        // Then, проверка результатов теста
        XCTAssertEqual(viewModel.posterImage, emptyData)    //convert не потерял данные картинки
        XCTAssertEqual(viewModel.question, "Question Text")  //convert не изменил текст вопроса
        XCTAssertEqual(viewModel.questionNumber, "1/10")     //convert посчитал номер вопроса правильно
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



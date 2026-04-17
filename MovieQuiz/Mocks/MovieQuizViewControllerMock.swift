//
//  Untitled.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 17.04.2026.
//
import Foundation

// MARK: - Mock class
// метод convert класса MovieQuizPresenter зависит от класса MovieQuizViewController
// создаем фиктивный ViewController, который реализует протокол при тестировании

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func showQuestion(quiz step: QuizStepViewModel) {}
    func showGameResult(quiz result: QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}

//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 13.04.2026.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showQuestion(quiz step: QuizStepViewModel)
    func showGameResult(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool) 
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}

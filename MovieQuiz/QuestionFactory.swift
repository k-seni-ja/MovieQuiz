//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 24.02.2026.
//

import Foundation

//MARK: - Mock Data

final class QuestionFactory {
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            imageName: "The Godfather",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "The Dark Knight",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "Kill Bill",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "The Avengers",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "Deadpool",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "The Green Knight",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "Old",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            imageName: "The Ice Age Adventures of Buck Wild",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            imageName: "Tesla",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            imageName: "Vivarium",
            textQuestion: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)]
    
    // выбор случайного вопроса
    func requestNextQuestion() -> QuizQuestion? {
        guard let index = (0 ..< questions.count).randomElement() else {
            return nil
        }
        return questions[safe: index]
    }
}

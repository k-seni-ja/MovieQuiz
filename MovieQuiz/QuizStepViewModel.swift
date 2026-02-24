//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 24.02.2026.
//
import UIKit

//MARK: - View Models

// состояние экрана  "Вопрос показан"
struct QuizStepViewModel {
    let posterImage: UIImage
    let question: String  // из questions: [QuizQuestion]
    let questionNumber: String
}

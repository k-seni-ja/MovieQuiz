//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 26.02.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)   
}

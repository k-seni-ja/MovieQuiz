//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 10.03.2026.
//
import UIKit

final class StatisticService: StatisticServiceProtocol {
    // убрать дублирование в коде
    private let storage: UserDefaults = .standard
    // cтроковые ключи
    private enum Keys: String {
        case gamesCount          // Для счётчика сыгранных игр
        case bestGameCorrect     // Для количества правильных ответов в лучшей игре
        case bestGameTotal       // Для общего количества вопросов в лучшей игре
        case bestGameDate        // Для даты лучшей игры
        case totalCorrectAnswers // Для общего количества правильных ответов за все игры
        case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
    }
    
    var gamesCount: Int { //общее количество завершенных игр
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult { //лучшая игра (правильные ответы, кол-во вопросов, дата)
        get {
            let currentResult = GameResult(
                correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date())
            return currentResult
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double { //средняя точность в %
        get {
            // общее количество правильных ответов за все игры
            let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
            // общее количество вопросов, заданных за все игры
            let totalQuestionsAsked = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
            if totalQuestionsAsked == 0 {
                return 0
            } else {
                return (Double(totalCorrectAnswers) / Double(totalQuestionsAsked)) * 100
            }
        }
    }
    
    // сохранение текущего результата игры
    func store(correct count: Int, total amount: Int) {
        //обновить количество сыгранных игр
        gamesCount += 1
        //обновить количество правильных ответов и количество заданных вопросов
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) + count
        storage.set(totalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let totalQuestionsAsked = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue) + amount
        storage.set(totalQuestionsAsked, forKey: Keys.totalQuestionsAsked.rawValue)
        
        // проверить лучший результат на текущий момент
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) == true {
            bestGame = currentGame
        }
    }
}

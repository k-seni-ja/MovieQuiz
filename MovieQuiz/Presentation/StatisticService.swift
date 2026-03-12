//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 10.03.2026.
//
import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    
    //MARK: - Properties
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
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
    
    var totalAccuracy: Double {
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestionsAsked = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        return totalQuestionsAsked == 0 ? 0 : (Double(totalCorrectAnswers) / Double(totalQuestionsAsked)) * 100
    }
    
    //MARK: - Methods
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        //обновить сохраненные данные
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) + count
        storage.set(totalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let totalQuestionsAsked = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue) + amount
        storage.set(totalQuestionsAsked, forKey: Keys.totalQuestionsAsked.rawValue)
        
        // проверить лучший результат на текущий момент
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}

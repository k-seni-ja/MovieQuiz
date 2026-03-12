//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 10.03.2026.
//

import UIKit

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    // сохранение текущего результата игры
    func store(correct count: Int, total amount: Int)
}

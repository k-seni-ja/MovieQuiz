//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 10.03.2026.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

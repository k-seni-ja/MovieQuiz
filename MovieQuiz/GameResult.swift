//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 10.03.2026.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        self.correct > another.correct
    }
}

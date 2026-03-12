//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 10.03.2026.
//

import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    // метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        self.correct > another.correct
    }
}

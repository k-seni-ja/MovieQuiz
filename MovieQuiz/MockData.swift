//
//  MockData.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 31.03.2026.
//

import Foundation

struct MockData {
// MARK: - JSON строка
static let jsonString = """
{  "errorMessage" : "",
   "items" : [
      {
         "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
         "fullTitle" : "Prey (2022)",
         "id" : "tt11866324",
         "imDbRating" : "7.2",
         "imDbRatingCount" : "93332",
         "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
         "rank" : "1",
         "rankUpDown" : "+23",
         "title" : "Prey",
         "year" : "2022"
      },
      {
         "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
         "fullTitle" : "The Gray Man (2022)",
         "id" : "tt1649418",
         "imDbRating" : "6.5",
         "imDbRatingCount" : "132890",
         "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
         "rank" : "2",
         "rankUpDown" : "-1",
         "title" : "The Gray Man",
         "year" : "2022"
      }
    ]
  }
"""
    
    // MARK: - готовый объект
    static var mostPopularMovies: MostPopularMovies? {
        guard let data = jsonString.data(using: .utf8) else {
            print("⁉️ Не удалось преобразовать jsonString в Data")
            return nil
        }
        do {
            let movies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
            print("✅ Успешно преобразовано jsonString в Data, фильмов: \(movies.items.count) ")
            return movies
        } catch {
            print("⁉️ Ошибка парсинга MOCK данных: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - массив фильмов
    static var movies: [MostPopularMovie] {
        return mostPopularMovies?.items ?? []
    }
}

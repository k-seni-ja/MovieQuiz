//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 24.02.2026.
//

import Foundation

//MARK: - Mock Data

final class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    private let moviesLoader: MoviesLoading
    init(moviesLoader: MoviesLoading) {
        self.moviesLoader = moviesLoader
    }
    private var movies: [MostPopularMovie] = []
    
    /*
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
     
     // выбор вопроса,вызов делегата
     func requestNextQuestion() {
     guard let index = (0..<questions.count).randomElement() else {
     delegate?.didReceiveNextQuestion(question: nil)
     return
     }
     
     let question = questions[safe: index]
     delegate?.didReceiveNextQuestion(question: question)
     }
     */
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
    
    func requestNextQuestion() {
        // запустим загрузку в другом потоке
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            // создание данных из URL
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            // Создаём вопрос, определяем его корректность и создаём модель вопроса
            let rating = Float(movie.rating) ?? 0 // превращаем строку в число
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            let question = QuizQuestion(imageData: imageData,
                                        textQuestion: text,
                                        correctAnswer: correctAnswer)
            // вернемся на главный поток
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}

//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 24.02.2026.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
  
    // 🔁 переключатель true = mock, false = API 🔁
    static var useMockData: Bool = true
    
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoadingProtocol
    weak var delegate: QuestionFactoryDelegate?
    
    init(delegate: QuestionFactoryDelegate, moviesLoader: MoviesLoadingProtocol) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    
    func loadData() {
        // загрузка из mock-данных, когда переключатель useMockData = true
        if QuestionFactory.useMockData {
            DispatchQueue.main.async { [weak self] in
                self?.movies = MockData.movies
                self?.delegate?.didLoadDataFromServer()
            }
            return
        }
        // загрузка из API
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    print(" 🎞️ loadData вызван, фильмы загрузились: \(mostPopularMovies.items.count)")
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    print(" ‼️ loadData вызван, ошибка загрузки фильмов: \(error)")
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func createQuestion(for movie: MostPopularMovie) -> (text: String, correctAnswer: Bool) {
        let rating = Float(movie.rating) ?? 0
        // генерируем сравнение
        let isGreaterThan = Bool.random() //true - больше чем, false - меньше чем
        
        // выбор случайного смещения для порога ( +- 0.1, +-0.5, +-1.0, +-1.5, +-5.0)
        let offsets: [Float] = [0.1, 0.5, 1.0, 1.5, 5.0]
        let randomOffset = offsets.randomElement() ?? 0.2
        var threshold: Float
        var correctAnswer: Bool
        
        if isGreaterThan {
            threshold = max(0, rating - randomOffset)
            correctAnswer = rating > threshold
        } else {
            threshold = min(10, rating + randomOffset)
            correctAnswer = rating < threshold
        }
        
        // Округляем порог до десятых
        let roundedThreshold = String(format: "%.1f", threshold)
        
        // Формируем текст вопроса
        let questionText = isGreaterThan
        ? "Рейтинг этого фильма больше чем \(roundedThreshold)?"
        : "Рейтинг этого фильма меньше чем \(roundedThreshold)?"
        return (text: questionText, correctAnswer: correctAnswer)
    }
    
    func requestNextQuestion() {
        // проверим наличие фильмов в массиве
        guard !movies.isEmpty else {
            print(" ⚠️ массив 'movies' пуст!")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let error = NSError(domain: "QuestionFactory", code: 0, userInfo: [NSLocalizedDescriptionKey: "Нет загруженных фильмов"])
                self.delegate?.didFailToLoadData(with: error)
            }
            return
        }
        
        // запустим загрузку в другом потоке
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            // создание данных из URL (загрузка картинки)
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
                if imageData.isEmpty {
                    throw NSError(domain: "ImageLoader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Пустое изобажение"])
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            // Создаём вопрос, определяем его корректность и создаём модель вопроса
            let questionData = self.createQuestion(for: movie)
            let question = QuizQuestion(imageData: imageData,
                                        textQuestion: questionData.text,
                                        correctAnswer: questionData.correctAnswer)
            // вернемся на главный поток
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}

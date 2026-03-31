//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 24.02.2026.
//

import Foundation

//MARK: - Mock Data
final class QuestionFactory: QuestionFactoryProtocol {
    // переключатель true = mock, false = API
    static var useMockData: Bool = true
    
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    init(moviesLoader: MoviesLoading) {
        self.moviesLoader = moviesLoader
    }
    
    
    func loadData() {
        // загрузка из mock-данных, когда переключатель useMockData = true
        if QuestionFactory.useMockData {
            DispatchQueue.main.async { [weak self] in
                self?.movies = MockData.movies //сохраняем массив mock-фильмов в нашу новую переменную
                self?.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились нашему MovieQuizViewController
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
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились нашему MovieQuizViewController
                case .failure(let error):
                    print(" ‼️ loadData вызван, ошибка загрузки фильмов: \(error)")
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
    
    func createQuestion(for movie: MostPopularMovie) -> (text: String, correctAnswer: Bool) {
        // получим рейтинг фильма
        let rating = Float(movie.rating) ?? 0
        // генерируем сравнение
        let isGreaterThan = Bool.random() //true - больше чем, false - меньше чем
        // выбор случайного смещения для порога (+-0.5, +-1.0, +-1.5)
        let offsets: [Float] = [0.5, 1.0, 1.5]
            let randomOffset = offsets.randomElement() ?? 0.5
            var threshold: Float
            var correctAnswer: Bool
            
            if isGreaterThan {
                // Вопрос "больше чем X?" — порог ниже рейтинга
                threshold = rating - randomOffset
                threshold = max(0, threshold)
                // Правильный ответ: true, если рейтинг фильма больше порога
                correctAnswer = rating > threshold
            } else {
                // Вопрос "меньше чем X?" — порог выше рейтинга
                threshold = rating + randomOffset
                threshold = min(10, threshold)
                // Правильный ответ: true, если рейтинг фильма меньше порога
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

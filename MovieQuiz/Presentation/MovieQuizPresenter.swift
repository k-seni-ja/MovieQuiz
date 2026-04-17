//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 10.04.2026.
//

import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    //MARK: - Dependencies
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol
    
    //MARK: - State
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    var currentQuestionIndex = 0
    var correctAnswers = 0
    
    // MARK: - init
    init(viewController: MovieQuizViewControllerProtocol) {
        self.statisticService = StatisticService()
        self.questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        self.viewController = viewController
        viewController.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // обновление UI в главной очереди
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuestion(quiz: viewModel)
        }
    }
    
    //сообщение об успешной загрузке данных
    func didLoadDataFromServer() {
        print(" ✅ didLoadDataFromServer вызван")
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    // сообщение об ошибке загрузки
    func didFailToLoadData(with error: Error) {
        print(" ⛔ didFailToLoadData вызван, ошибка загрузки: \(error.localizedDescription)")
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    //MARK: - Methods
    // конвертируем модель данных QuizQuestion во View Model (готовим данные для отображения)
    func convert (model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            posterImage: model.imageData,
            question: model.textQuestion,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {return}
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // выбор между состояниями экрана "конец игры" / "вопрос"
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let viewModelAlert = QuizResultsViewModel(
                titleAlert: "Этот раунд окончен!",
                textAlert: """
                Ваш результат: \(correctAnswers)/10
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))% 
                """,
                buttonTextAlert: "Сыграть ещё раз")
            
            viewController?.showGameResult(quiz: viewModelAlert)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    //  рамка, отображающая результат каждого раунда
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            // код, который мы хотим вызвать через 1 секунду
            self.proceedToNextQuestionOrResults()
        }
    }
}

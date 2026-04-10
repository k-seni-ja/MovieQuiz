//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 10.04.2026.
//

import Foundation

final class MovieQuizPresenter {
    //ссылка на MovieQuizViewController
    weak var viewController: MovieQuizViewController?
    
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    var correctAnswers = 0
    var questionFactory: QuestionFactoryProtocol?
    
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
    
    //MARK: - Methods
    // конвертируем модель данных questions[currentQuestionIndex] во View Model (готовим данные для отображения)
    func convert (model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            posterImage: model.imageData,
            question: model.textQuestion,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func isLastQuestion () -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // выбор между состояниями экрана "конец игры" / "вопрос"
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let viewController = self.viewController else {return}
            viewController.statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let viewModelAlert = QuizResultsViewModel(
                titleAlert: "Этот раунд окончен!",
                textAlert: """
                Ваш результат: \(correctAnswers)/10
                Количество сыгранных квизов: \(viewController.statisticService.gamesCount)
                Рекорд: \(viewController.statisticService.bestGame.correct)/\(viewController.statisticService.bestGame.total) (\(viewController.statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", viewController.statisticService.totalAccuracy))% 
                """,
                buttonTextAlert: "Сыграть ещё раз")
            
            viewController.showGameResult(quiz: viewModelAlert)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer (isYes: Bool) {
        guard let currentQuestion else {return}
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
}

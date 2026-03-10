import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    //MARK: - Properties
    // индекс текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    // счётчик правильных ответов, начальное значение 0
    private var correctAnswers = 0
    //общее количество вопросов
    private let questionsAmount: Int = 10
    // фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    //вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    // отображение Алерта
    private let alertPresenter = AlertPresenter()
    // статистика предыдущих игр
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // внедрение зависимости делегату
        let factory = QuestionFactory()
        factory.setup(delegate: self)
        self.questionFactory = factory
        
        // показать 1 вопрос при загрузке (из фабрики вопросов)
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        // обновление UI в главной очереди
        DispatchQueue.main.async { [weak self] in
            self?.showQuestion(quiz: viewModel)
        }
    }
    //MARK: - Methods
    // конвертируем модель данных questions[currentQuestionIndex] во View Model (готовим данные для отображения)
    private func convert (model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            posterImage: UIImage(named: model.imageName) ?? UIImage(),
            question: model.textQuestion,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // показ состояния экрана "вопрос"
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.posterImage
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        // разблокировка кнопок
        noButton.isEnabled = true
        yesButton.isEnabled = true
        
        // уберем рамку перед следующим вопросом
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    //  рамка, отображающая результат каждого раунда
    private func showAnswerResult(isCorrect: Bool) {
        // блокировка кнопок
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
    
    // выбор между состояниями экрана "конец игры" / "вопрос"
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let viewModelAlert = QuizResultsViewModel(
                titleAlert: "Этот раунд окончен!",
                textAlert: """
                Ваш результат: \(correctAnswers)/10
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f",statisticService.totalAccuracy))% 
                """,
                buttonTextAlert: "Сыграть ещё раз")
            showResults(quiz: viewModelAlert)
            statisticService.store(correct: correctAnswers, total: questionsAmount)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // показ состояния экрана "конец игры"
    func showResults(quiz result: QuizResultsViewModel) {
        // блокировка кнопок
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        let model = AlertModel(
            titleAlert: result.titleAlert,
            messageAlert: result.textAlert,
            buttonTextAlert: result.buttonTextAlert) { [weak self] in
                guard let self = self else {return}
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            }
        alertPresenter.showResults(in: self, model: model)
    }
    
    //MARK: - IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
}


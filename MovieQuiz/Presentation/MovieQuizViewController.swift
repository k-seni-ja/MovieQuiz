import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Properties
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private let alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        // внедрение зависимости делегату
        let factory = QuestionFactory(moviesLoader: MoviesLoader())
        factory.setup(delegate: self)
        self.questionFactory = factory
        
       // загружаем первый вопрос из сервера
        self.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}
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
            posterImage: UIImage(data: model.imageData) ?? UIImage(),
            question: model.textQuestion,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // показ состояния экрана "вопрос"
    private func showQuestion(quiz step: QuizStepViewModel) {
        noButton.isEnabled = true
        yesButton.isEnabled = true
        
        imageView.image = step.posterImage
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //  рамка, отображающая результат каждого раунда
    private func showAnswerResult(isCorrect: Bool) {
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
            statisticService.store(correct: correctAnswers, total: questionsAmount)
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
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // показ состояния экрана "конец игры"
    private func showResults(quiz result: QuizResultsViewModel) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        let model = AlertModel(titleAlert: result.titleAlert,
                               messageAlert: result.textAlert,
                               buttonTextAlert: result.buttonTextAlert) { [weak self] in
            guard let self else {return}
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.showResults(in: self, model: model)
    }
    
    // показ индикатора загрузки данных
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    //Alert с ошибкой загрузки из сервера
    private func showNetworkError(message: String) {
        
        let model = AlertModel(titleAlert: "Ошибка",
                               messageAlert: message,
                               buttonTextAlert: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        alertPresenter.showResults(in: self, model: model)
    }
    
    //сообщение об успешной загрузке данных
    func didLoadDataFromServer() {
        print(" ✅ didLoadDataFromServer вызван")
        activityIndicator.stopAnimating() // выключаем анимацию
        questionFactory?.requestNextQuestion()
    }
    
    // сообщение об ошибке загрузки
    func didFailToLoadData(with error: Error) {
        print(" ⛔ didFailToLoadData вызван, ошибка загрузки: \(error.localizedDescription)")
        activityIndicator.stopAnimating() // выключаем анимацию
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    //MARK: - IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {return}
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {return}
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
}


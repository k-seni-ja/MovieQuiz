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
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    
    
    
    private let alertPresenter = AlertPresenter()
    var statisticService: StatisticServiceProtocol = StatisticService()
    private let presenter = MovieQuizPresenter()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        // внедрение зависимости делегату
        let factory = QuestionFactory(moviesLoader: MoviesLoader())
        factory.setup(delegate: self)
        self.questionFactory = factory
        
        //внедрение зависимости MovieQuizPresenter
        presenter.viewController = self
        
       // загружаем первый вопрос из сервера
        self.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    //MARK: - Methods
    
    // показ состояния экрана "вопрос"
    func showQuestion(quiz step: QuizStepViewModel) {
        noButton.isEnabled = true
        yesButton.isEnabled = true
        
        imageView.image = UIImage(data: step.posterImage) ?? UIImage() // преобразуем Data в UIImage
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //  рамка, отображающая результат каждого раунда
    func showAnswerResult(isCorrect: Bool) {
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
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }

    // показ состояния экрана "конец игры"
    func showGameResult(quiz result: QuizResultsViewModel) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        let model = AlertModel(titleAlert: result.titleAlert,
                               messageAlert: result.textAlert,
                               buttonTextAlert: result.buttonTextAlert,
                               accessibilityIdentifier: "Game result") { [weak self] in
            guard let self else {return}
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
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
                               buttonTextAlert: "Попробовать еще раз",
                               accessibilityIdentifier: "Loading error") { [weak self] in
            guard let self = self else { return }
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
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
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}


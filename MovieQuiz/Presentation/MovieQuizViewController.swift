import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Properties
    
    private let alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //внедрение зависимости MovieQuizPresenter
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
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
    func highlightImageBorder(isCorrectAnswer: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
    }
    
    // Alert состояния экрана "конец игры"
    func showGameResult(quiz result: QuizResultsViewModel) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        let model = AlertModel(titleAlert: result.titleAlert,
                               messageAlert: result.textAlert,
                               buttonTextAlert: result.buttonTextAlert,
                               accessibilityIdentifier: "Game result") { [weak self] in
            guard let self else {return}
            self.presenter?.restartGame()
        }
        alertPresenter.showResults(in: self, model: model)
    }
    
    //Alert с ошибкой загрузки из сервера
    func showNetworkError(message: String) {
        
        let model = AlertModel(titleAlert: "Ошибка",
                               messageAlert: message,
                               buttonTextAlert: "Попробовать еще раз",
                               accessibilityIdentifier: "Loading error") { [weak self] in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.presenter?.restartGame()
        }
        alertPresenter.showResults(in: self, model: model)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    //MARK: - IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
}


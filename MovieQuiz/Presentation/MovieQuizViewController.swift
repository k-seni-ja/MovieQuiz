import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: - Models & Mock Data
    private struct QuizQuestion {
        let imageName: String
        let textQuestion: String
        let correctAnswer: Bool
    }
    
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
    
    
    //MARK: - View Models
    // состояние "Вопрос показан"
    private struct QuizStepViewModel {
        let posterImage: UIImage
        let question: String  // из questions: [QuizQuestion]
        let questionNumber: String
    }
    // состояние "Результат квиза"
    private struct QuizResultsViewModel {
        let titleAlert: String
        let textAlert: String // количество набранных очков
        let buttonTextAlert: String
    }
    
    //MARK: - IBOutlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    //MARK: - Properties
    // индекс текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    // счётчик правильных ответов, начальное значение 0
    private var correctAnswers = 0
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // показать 1 вопрос при загрузке (из массива вопросов по индексу текущего вопроса)
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        showQuestion(quiz: viewModel)
    }
    
    
    //MARK: - Methods
    // конвертируем модель данных questions[currentQuestionIndex] во view Model (готовим данные для отображения)
    private func convert (model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            posterImage: UIImage(named: model.imageName) ?? UIImage(),
            question: model.textQuestion,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    // показ состояния экрана "вопрос"
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.posterImage
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // уберем рамку перед следующим вопросом
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    //  рамка, отображающая результат каждого раунда
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
    
    // показ состояния экрана "конец игры"
    private func showResults(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.titleAlert,
            message: result.textAlert,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonTextAlert, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.showQuestion(quiz: viewModel)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // выбор между состояниями экрана "конец игры" / "вопрос"
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let viewModelAlert = QuizResultsViewModel(
                titleAlert: "Этот раунд окончен!",
                textAlert: "Ваш результат: \(correctAnswers)/10",
                buttonTextAlert: "Сыграть ещё раз")
            showResults(quiz: viewModelAlert)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            showQuestion(quiz: viewModel)
        }
    }
    
    //MARK: - IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
}



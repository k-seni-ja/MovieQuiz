//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 03.03.2026.
//


import UIKit

final class AlertPresenter {
    
    func showResults(in controller: UIViewController, model: AlertModel) {
        
        let alert = UIAlertController(
            title: model.titleAlert,
            message: model.messageAlert,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: model.buttonTextAlert,
            style: .default) { _ in
                model.completion()
            }
        
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}

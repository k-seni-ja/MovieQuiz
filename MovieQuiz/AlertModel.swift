//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 03.03.2026.
//

import UIKit

//MARK: - Model Alert

// модель всплывающего окна
struct AlertModel {
    var titleAlert: String
    var messageAlert: String // текст сообщения алерта
    var buttonTextAlert: String
    var completion: () -> Void
}

//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 03.03.2026.
//

import Foundation

//MARK: - Model Alert

struct AlertModel {
    let titleAlert: String
    let messageAlert: String
    let buttonTextAlert: String
    let completion: () -> Void
}

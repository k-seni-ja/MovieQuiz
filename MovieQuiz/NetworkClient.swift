//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 23.03.2026.
//
import Foundation

// Отправка HTTP запросов, получение данных
struct NetworkClient: NetworkServiceProtocol {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result <Data, Error>) -> Void) {
        //HTTP запроос
        let request = URLRequest(url: url)
        //Задача для загрузки данных
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Проверка ошибки сети
            if let error = error {
                handler(.failure(error))
                return
            }
            // Проверка HTTP статуса
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}

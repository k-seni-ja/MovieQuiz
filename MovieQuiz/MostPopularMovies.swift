//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Ксения Штыркова on 23.03.2026.
//

import Foundation

struct MostPopularMovies: Codable {
    let items: [MostPopularMovie]
    let errorMessage: String
}


struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    // экономия трафика (уменьшим размер картинки)
    var resizedImageURL: URL {
        // создаем строку из адреса
        let urlString = imageURL.absoluteString
        //  обрезаем лишнюю часть картинки и добавляем модификатор желаемого качества
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        // пытаемся создать новый адрес, если не получается возвращаем старый
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        return newURL
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}


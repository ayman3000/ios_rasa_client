//
//  RasaResponse.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 11/04/2023.
//

//import Foundation
struct RasaResponse: Decodable {
    let text: String
    let quick_replies: [QuickReply]?

    struct QuickReply: Decodable {
        let title: String
        let content_type: String
        let payload: String

        private enum CodingKeys: String, CodingKey {
            case title
            case content_type = "content_type"
            case payload
        }
    }
}


//
//  ApiError.swift
//  Tap to Pay Sample App
//
//  Created by Allan Cheng on 12/23/25.
//

import Foundation

struct ApiErrorResponse: Decodable {
    let errors: [ApiError]
}

struct ApiError: Decodable {
    let code: String
    let message: String
}

struct ApiErrorMapper {
    static func map(statusCode: Int, data: Data?) -> AppError {

        // Auth shortcut
        if statusCode == 401 {
            return .unauthorized
        }

        guard let data = data,
              let errorResponse = try? JSONDecoder().decode(ApiErrorResponse.self, from: data),
              !errorResponse.errors.isEmpty else {
            
            return .unknown
        }

        for error in errorResponse.errors {
            switch error.code {
            case "unauthorized-error":
                return .unauthorized
            default:
                continue
            }
        }

        // Fallback: show all server messages
        let messages = errorResponse.errors.map { $0.message }
        return .server(messages: messages)
    }
}

enum AppError: LocalizedError {
    case unauthorized
    case failure(errorDescription: String?)
    case server(messages: [String])
    case invalidEndpoint
    case unknown

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Authorization failed. Please check your API key."
        case .failure(let errorDescription):
            return errorDescription ?? "There was an error! Please try again."
        case .server(let messages):
            return messages.joined(separator: "\n")
        case .invalidEndpoint:
            return "Invalid API endpoint."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}

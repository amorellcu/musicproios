//
//  ApiError.swift
//  musicprof
//
//  Created by John Doe on 6/21/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct ApiError: Error, Decodable {
    var message: String
    var success: Bool
}

extension ApiError: CustomStringConvertible {
    var description: String {
        return self.message
    }
}

extension ApiError {
    init(message: String) {
        self.init(message: message, success: false)
    }
    
    static func from(jsonData data: Data) throws -> ApiError {
        let decoder = JSONDecoder()
        let item = try decoder.decode(ApiError.self, from: data)
        guard !item.success else {
            throw AppError.unexpected
        }
        return item
    }
}

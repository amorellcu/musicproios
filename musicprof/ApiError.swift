//
//  ApiError.swift
//  musicprof
//
//  Created by John Doe on 6/21/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct ApiError: Error, Decodable {
    var result: String?
    var code: Int
    var message: String?
}

extension ApiError: CustomStringConvertible {
    var description: String {
        return self.message ?? "Error \(self.code) en el servidor."
    }
}

extension ApiError {
    init(code: Int, message: String?) {
        self.init(result: "Error", code: code, message: message)
    }
    
    static func from(jsonData data: Data) throws -> ApiError {
        let decoder = JSONDecoder()
        let item = try decoder.decode(ApiError.self, from: data)
        guard item.result != "OK" else {
            throw AppError.unexpected
        }
        return item
    }
}

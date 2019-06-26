//
//  ServiceResult.swift
//  musicprof
//
//  Created by John Doe on 6/21/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

enum ApiResult<T> {
    case success(data: T)
    case failure(error: Error)
}

extension ApiResult {
    func transform<K>(with function: (T) throws -> K) -> ApiResult<K> {
        do {
            switch self {
            case .success(let data):
                return .success(data: try function(data))
            case .failure(let error):
                return .failure(error: error)
            }
        } catch {
            return .failure(error: error)
        }
    }
}

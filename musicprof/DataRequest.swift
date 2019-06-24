//
//  DataRequest.swift
//  musicprof
//
//  Created by John Doe on 6/22/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation
import Alamofire

private struct ValidResponse<T: Decodable>: Decodable {
    var result: String
    var data: T
    var code: Int?
    var message: String?
}

extension DataRequest {
    private class func decodeResponse<T: Decodable>(from response: DataResponse<Data>) throws -> T {
        guard let responseData = response.data else {
            throw AppError.unexpected
        }
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        dateFormatter.calendar = Calendar.current
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let item = try decoder.decode(T.self, from: responseData)
        return item
    }
    
    private func logRequest(from response: DataResponse<Data>) {
        print(">>>>>>>>>>>>>>")
        if let url = response.request?.url {
            print(url.description)
        }
        if let request = response.request?.httpBody, let json = String(data: request, encoding: .utf8) {
            print(json.description)
        }
    }
    
    private func logResponse(_ response: DataResponse<Data>) {
        if let data = response.data, let json = String(data: data, encoding: .utf8) {
            print("<<<<<<<<<<<<<<\n \(json)")
        }
    }
    
    func responseDecodable<T: Decodable>(completionHandler: @escaping (ApiResult<T>) -> Void) -> DataRequest {
        return self.responseData { responseData in
            do {
                self.logRequest(from: responseData)
                self.logResponse(responseData)
                var data : ValidResponse<T> = try DataRequest.decodeResponse(from: responseData)
                data.code = data.code ?? responseData.response?.statusCode
                if let code = data.code, (200..<300).contains(code) {
                    completionHandler(ApiResult<T>.success(data: data.data))
                } else if let code = data.code {
                    let error = ApiError(result: data.result, code: code, message: data.message)
                    completionHandler(.failure(error: error))
                } else {
                    completionHandler(.failure(error: AppError.unsupportedData))
                }
            } catch {
                let serviceError = responseData.data == nil
                    ? nil
                    : try? ApiError.from(jsonData: responseData.data!)
                let error = serviceError ?? responseData.error ?? error
                completionHandler(.failure(error: error))
            }
        }
    }
    
    func responseError(completionHandler: @escaping (ApiResult<Void>) -> Void) -> DataRequest {
        return self.responseData { responseData in
            self.logRequest(from: responseData)
            self.logResponse(responseData)
            var serviceError: Error? = nil
            if let data = responseData.data {
                do {
                    serviceError = try ApiError.from(jsonData: data)
                } catch AppError.notAnError {
                    return completionHandler(.success(data: ()))
                } catch {
                    serviceError = error
                }
            }
            completionHandler(.failure(error: serviceError ?? AppError.unsupportedData))
        }
    }
}


//
//  ApiManager.swift
//  musicprof
//
//  Created by John Doe on 6/21/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftKeychainWrapper

class ApiManager {
    static let shared = ApiManager()
    
    let keychain = KeychainWrapper(serviceName: "\(Bundle.main.bundleIdentifier!).session")
    
    let headers = ["Accept": "application/json"]
    let baseUrl: URL = URL(string: "http://musicprof.softok2.mx/api")!
    
    let session: SessionManager
    let imageDownloader: ImageDownloader
    
    private(set) var user: Client? {
        didSet {
            if let user = self.user {
                self.keychain.set(user, forKey: "user")
            } else {
                self.keychain.removeObject(forKey: "user")
            }
        }
    }
    
    var isSignedIn: Bool {
        return self.user != nil && self.session.adapter != nil
    }
    
    init() {
        self.session = SessionManager(configuration: .default)        
        self.imageDownloader = ImageDownloader.default
        
        self.restoreFromKeychain()
    }
    
    private func restoreFromKeychain() {
        let adapter = self.keychain.object(forKey: "adapter") as? JWTAccessTokenAdapter
        adapter?.baseUrl = self.baseUrl
        self.session.adapter = adapter
        self.session.retrier = adapter
        self.user = self.keychain.object(forKey: "user") as? Client
    }
    
    func createAdapter(accessToken: String, refreshToken: String) {
        let adapter = JWTAccessTokenAdapter(baseUrl: self.baseUrl, accessToken: accessToken, refreshToken: refreshToken)
        self.keychain.set(adapter, forKey: "adapter")
        self.session.adapter = adapter
        self.session.retrier = adapter
    }
    
    func signIn(withEmail userName: String, password: String,
                handler: @escaping (ApiResult<Client>) -> Void) {
        self.signOut()
        
        let url = baseUrl.appendingPathComponent("loginClient")
        let parameters = ["email": userName, "password": password]
        let _ = self.session
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<LoginData>) in
                switch result {
                case .success(let data):
                    self.createAdapter(accessToken: data.token, refreshToken: "")
                    self.user = data.client
                    handler(.success(data: data.client))
                case .failure(let error):
                    handler(.failure(error: error))
                }
            }
    }
    
    func signIn(withFacebookToken accessToken: String,
                handler: @escaping (ApiResult<Client>) -> Void) {
        self.signOut()
        
        let url = baseUrl.appendingPathComponent("loginWithFacebook")
        let parameters = ["accessToken": accessToken]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<LoginData>) in
                switch result {
                case .success(let data):
                    self.createAdapter(accessToken: data.token, refreshToken: "")
                    self.user = data.client
                    handler(.success(data: data.client))
                case .failure(let error):
                    handler(.failure(error: error))
                }
        }
    }
    
    func signOut() {
        self.session.adapter = nil
        self.session.retrier = nil
        self.user = nil
        self.keychain.removeObject(forKey: "adapter")
    }
    
    func getUserInfo(handler: @escaping (ApiResult<Client>) -> Void) {
        guard let userId = self.user?.id else {
            handler(.failure(error: AppError.invalidOperation))
            return
        }
        
        let url = baseUrl.appendingPathComponent("getClientData")
        let parameters = ["clientId": userId]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<UserDate>) in
                switch result {
                case .success(let data):
                    self.user = data.client
                    handler(.success(data: data.client))
                case .failure(let error):
                    handler(.failure(error: error))
                }
        }
    }
    
    func updateAddress(_ address: String, handler: @escaping (ApiResult<Void>) -> Void) {
        guard let userId = self.user?.id else {
            handler(.failure(error: AppError.invalidOperation))
            return
        }
        let url = baseUrl.appendingPathComponent("updateAddress")
        let parameters: Parameters = ["id": userId, "address": address]
        let _ = self.session
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseError(completionHandler: handler)        
    }
    
    private func post<T: Encodable>(_ encodable: T, to url: URL, handler: @escaping (ApiResult<Void>) -> Void) {
        var data: Data
        do {
            let encoder = JSONEncoder()
            data = try encoder.encode(encodable)
        } catch {
            handler(.failure(error: error))
            return
        }
        let _ = self.session
            .upload(data, to: url,
                    method: .post,
                    headers: headers)
            .validate()
            .responseError(completionHandler: handler)
    }
    
    private func post<T: Encodable, R: Decodable>(_ encodable: T, to url: URL, handler: @escaping (ApiResult<R>) -> Void) {
        var data: Data
        do {
            let encoder = JSONEncoder()
            data = try encoder.encode(encodable)
        } catch {
            handler(.failure(error: error))
            return
        }
        let _ = self.session
            .upload(data, to: url,
                    method: .post,
                    headers: headers)
            .validate()
            .responseDecodable(completionHandler: handler)
    }
    
    func makeReservation(_ request: ReservationRequest,
                         handler: @escaping (ApiResult<Void>) -> Void) {
        let url = baseUrl.appendingPathComponent("classReservation")
        self.post(request, to: url, handler: handler)
    }
}

private struct LoginData: Decodable {
    var token: String
    var client: Client
}

private struct UserDate: Decodable {
    var client: Client
}

class JWTAccessTokenAdapter : NSObject, RequestAdapter, RequestRetrier, NSCoding {
    
    private var accessToken: String
    private var refreshToken: String
    var baseUrl: URL
    
    init(baseUrl: URL, accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.baseUrl = baseUrl
    }
    
    required convenience init?(coder: NSCoder) {
        guard let accessToken = coder.decodeObject(forKey: "accessToken") as? String else { return nil }
        guard let refreshToken = coder.decodeObject(forKey: "refreshToken") as? String else { return nil }
        guard let urlString = coder.decodeObject(forKey: "baseUrl") as? String, let baseUrl = URL(string: urlString) else { return nil }
        self.init(baseUrl: baseUrl, accessToken: accessToken, refreshToken: refreshToken)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.accessToken, forKey: "accessToken")
        coder.encode(self.refreshToken, forKey: "refreshToken")
        coder.encode(self.baseUrl.description, forKey: "baseUrl")
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, !urlString.hasSuffix("/login") {
            /// Set the Authorization header value using the access token.
            urlRequest.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
    
    func refreshToken(handler: @escaping (Error?) -> Void) {
        let url = self.baseUrl.appendingPathComponent("refresh_token")
        let parameters: Parameters = ["refresh_token": self.refreshToken]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { data in
                if data.result.isSuccess, let json = data.result.value as? [String:Any],
                    let accessToken = json["access_token"] as? String,
                    let refreshToken = json["refresh_token"] as? String,
                    json["token_type"] as? String == "Bearer" {
                    self.accessToken = accessToken
                    self.refreshToken = refreshToken
                    handler(nil)
                } else {
                    handler(data.error ?? AppError.unexpected)
                }
        }
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        
        let nsError = error as NSError
        guard nsError.domain != NSCocoaErrorDomain || nsError.code != NSURLErrorTimedOut else {
            return completion(true, 5.0)
        }
        
        guard let afError = error as? AFError, afError.responseCode == 401 else {
            return completion(false, 0.0)
        }
        
        self.refreshToken { error in
            completion(error == nil, 0.0)
        }
    }
}

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
    
    var userId: String?
    
    init() {
        self.session = SessionManager(configuration: .default)        
        self.imageDownloader = ImageDownloader.default
    }
    
    func saveState(coder: NSCoder) {
        guard let adapter = self.session.adapter as? JWTAccessTokenAdapter, let userId = self.userId else { return }
        adapter.encode(with: coder)
        coder.encode(userId, forKey: "userId")
    }
    
    func restoreFromKeychain() {
        self.userId = self.keychain.string(forKey: "userId")
        let adapter = self.keychain.object(forKey: "adapter") as? JWTAccessTokenAdapter
        adapter?.baseUrl = self.baseUrl
        self.session.adapter = adapter
        self.session.retrier = adapter
    }
    
    func createAdapter(accessToken: String, refreshToken: String) {
        let adapter = JWTAccessTokenAdapter(baseUrl: self.baseUrl, accessToken: accessToken, refreshToken: refreshToken)
        self.keychain.set(adapter, forKey: "adapter")
        self.session.adapter = adapter
        self.session.retrier = adapter
    }
    
    func signIn(userName: String, password: String,
                handler: @escaping (ApiResult<Void>) -> Void) {
        self.signOut()
        
        let url = baseUrl.appendingPathComponent("loginClient")
        let parameters = ["email": userName, "password": password]
        self.session
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.default,
                     headers: self.headers)
            .validate()
            .responseJSON { [weak self] data in
                if data.result.isSuccess, let json = data.result.value as? [String:Any],
                    let code = json["code"] as? Int, (200..<300).contains(code),
                    let data = json["data"] as? [String:Any],
                    let token = data["token"] as? String {
                    self?.userId = (data["client"] as? [String:Any])?["users_id"] as? String
                    self?.createAdapter(accessToken: token, refreshToken: "")
                    handler(.success(data: ()))
                } else {
                    let serviceError = data.data == nil ? nil : try? ApiError.from(jsonData: data.data!)
                    handler(.failure(error: serviceError ?? data.error ?? AppError.unexpected))
                }
        }
    }
    
    func signOut() {
        self.session.adapter = nil
        self.session.retrier = nil
        self.userId = nil
        self.keychain.removeObject(forKey: "adapter")
    }
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


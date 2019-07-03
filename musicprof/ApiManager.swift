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
import FacebookCore
import FacebookLogin

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
        let url = baseUrl.appendingPathComponent("loginWithFacebook")
        let parameters = ["accessToken": accessToken]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<FBLoginData>) in
                switch result {
                case .success(let data):
                    guard let token = data.token, let client = data.client else {
                        return handler(.failure(error: AppError.registrationRequired))
                    }
                    self.createAdapter(accessToken: token, refreshToken: "")
                    self.user = data.client
                    handler(.success(data: client))
                case .failure(let error):
                    handler(.failure(error: error))
                }
        }
    }
    
    func signOut() {
        if AccessToken.current != nil {
            LoginManager().logOut()
        }        
        self.session.adapter = nil
        self.session.retrier = nil
        self.user = nil
        self.keychain.removeObject(forKey: "adapter")
    }
    
    func getPaypalToken(handler: @escaping (ApiResult<String>) -> Void) {
        let testingToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJleUowZVhBaU9pSktWMVFpTENKaGJHY2lPaUpGVXpJMU5pSXNJbXRwWkNJNklqSXdNVGd3TkRJMk1UWXRjMkZ1WkdKdmVDSjkuZXlKbGVIQWlPakUxTmpJeE5UZzNOemtzSW1wMGFTSTZJak00TjJRME5qSmlMVEJoTVdRdE5EaGtZeTA0TVRKbUxXRTJNVEkyWlRBMU1qRmlaU0lzSW5OMVlpSTZJak0wT0hCck9XTm5aak5pWjNsM01tSWlMQ0pwYzNNaU9pSkJkWFJvZVNJc0ltMWxjbU5vWVc1MElqcDdJbkIxWW14cFkxOXBaQ0k2SWpNME9IQnJPV05uWmpOaVozbDNNbUlpTENKMlpYSnBabmxmWTJGeVpGOWllVjlrWldaaGRXeDBJanBtWVd4elpYMHNJbkpwWjJoMGN5STZXeUp0WVc1aFoyVmZkbUYxYkhRaVhTd2liM0IwYVc5dWN5STZlMzE5LkJqck1rVEZZbEJ0NEpBNGtrSWJkVTBxVUFoVG1aZzlfaVlJNms4UW5naVNJRFhwdGlqNURlX241ZXphOHNOSk44b3Q0RDNmUXgzNTBIdTNFVlU2WE53IiwiY29uZmlnVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaS92MS9jb25maWd1cmF0aW9uIiwiZ3JhcGhRTCI6eyJ1cmwiOiJodHRwczovL3BheW1lbnRzLnNhbmRib3guYnJhaW50cmVlLWFwaS5jb20vZ3JhcGhxbCIsImRhdGUiOiIyMDE4LTA1LTA4In0sImNoYWxsZW5nZXMiOltdLCJlbnZpcm9ubWVudCI6InNhbmRib3giLCJjbGllbnRBcGlVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhdXRoVXJsIjoiaHR0cHM6Ly9hdXRoLnZlbm1vLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhbmFseXRpY3MiOnsidXJsIjoiaHR0cHM6Ly9vcmlnaW4tYW5hbHl0aWNzLXNhbmQuc2FuZGJveC5icmFpbnRyZWUtYXBpLmNvbS8zNDhwazljZ2YzYmd5dzJiIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInBheXBhbEVuYWJsZWQiOnRydWUsInBheXBhbCI6eyJkaXNwbGF5TmFtZSI6IkFjbWUgV2lkZ2V0cywgTHRkLiAoU2FuZGJveCkiLCJjbGllbnRJZCI6bnVsbCwicHJpdmFjeVVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS9wcCIsInVzZXJBZ3JlZW1lbnRVcmwiOiJodHRwOi8vZXhhbXBsZS5jb20vdG9zIiwiYmFzZVVybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9jaGVja291dC5wYXlwYWwuY29tIiwiZGlyZWN0QmFzZVVybCI6bnVsbCwiYWxsb3dIdHRwIjp0cnVlLCJlbnZpcm9ubWVudE5vTmV0d29yayI6dHJ1ZSwiZW52aXJvbm1lbnQiOiJvZmZsaW5lIiwidW52ZXR0ZWRNZXJjaGFudCI6ZmFsc2UsImJyYWludHJlZUNsaWVudElkIjoibWFzdGVyY2xpZW50MyIsImJpbGxpbmdBZ3JlZW1lbnRzRW5hYmxlZCI6dHJ1ZSwibWVyY2hhbnRBY2NvdW50SWQiOiJhY21ld2lkZ2V0c2x0ZHNhbmRib3giLCJjdXJyZW5jeUlzb0NvZGUiOiJVU0QifSwibWVyY2hhbnRJZCI6IjM0OHBrOWNnZjNiZ3l3MmIiLCJ2ZW5tbyI6Im9mZiJ9"
        handler(.success(data: testingToken))
    }
    
    func performPaypalPayment(withToken: String, handler: @escaping (ApiResult<Void>) -> Void) {
        handler(.success(data: ()))
    }
    
    func getClient(withId id: Int) -> Client? {
        guard let user = self.user else { return nil }
        if user.id == id {
            return user
        }
        return user.subaccounts?.first(where: {$0.id == id})
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
            .responseDecodable { (result: ApiResult<UserData>) in
                switch result {
                case .success(let data):
                    self.user = data.client
                    handler(.success(data: data.client))
                case .failure(let error):
                    handler(.failure(error: error))
                }
        }
    }
    
    func getInstruments(handler: @escaping (ApiResult<[Instrument]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getInstruments")
        let _ = self.session
            .request(url, method: .get,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<InstrumentData>) in
                handler(result.transform(with: {$0.instruments}))
        }
    }
    
    func getLocations(name: String? = nil, stateId: Int? = nil, cityId: Int? = nil,
                      handler: @escaping (ApiResult<[Location]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getColonias")
        var parameters: Parameters = [:]
        if let name = name {
            parameters["name"] = name
        }
        if let stateId = stateId {
            parameters["stateId"] = stateId
        }
        if let cityId = cityId {
            parameters["municipioId"] = cityId
        }
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<LocationData>) in
                handler(result.transform(with: {$0.locations}))
        }
    }
    
    func getLocation(withId id: Int, handler: @escaping (ApiResult<Location>) -> Void) {
        let url = baseUrl.appendingPathComponent("getColonia")
        let parameters: Parameters = ["idcolonia": id]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<[Location]>) in
                handler(result.transform(with: {
                    guard let result = $0.first else {
                        throw AppError.unsupportedData
                    }
                    return result
                }))
        }
    }
    
    func getLocations(at address: String, handler: @escaping (ApiResult<[Location]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getSublocality")
        let parameters: Parameters = ["address": address]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<LocationData>) in
                handler(result.transform(with: {$0.locations}))
        }
    }
    
    func getAvailableDays(for request: ReservationRequest, inMonth month: Int, handler: @escaping (ApiResult<[Date]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getAvailableClassOnMonth")
        let parameters: Parameters = ["coloniaId": request.locationId as Any,
                                      "instrumentId": request.instrument?.id as Any,
                                      "month": month]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable(completionHandler: handler)
    }
    
    func getAvailableProfessors(for request: ReservationRequest, inDay date: Date, handler: @escaping (ApiResult<[Professor]>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        
        let url = baseUrl.appendingPathComponent("getAvailableProfesorsOnDate")
        let parameters: Parameters = ["coloniaId": request.locationId as Any,
                                      "instrumentId": request.instrument?.id as Any,
                                      "date": dateStr]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable(completionHandler: handler)
    }
    
    func getAvailableProfessors(for request: ReservationRequest, handler: @escaping (ApiResult<[Professor]>) -> Void) {
        guard let date = request.date else {
            return handler(.failure(error: AppError.invalidOperation))
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFormatter.string(from: date)
        
        let url = baseUrl.appendingPathComponent("getAvailableProfesors")
        let parameters: Parameters = ["coloniaId": request.locationId as Any,
                                      "instrumentId": request.instrument?.id as Any,
                                      "date": dateStr]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable(completionHandler: handler)
    }
    
    func getPackages(forStateWithId stateId: Int? = nil, handler: @escaping (ApiResult<[Package]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getPackages")
        var parameters: Parameters = [:]
        if let stateId = stateId {
            parameters["estadoId"] = stateId
        }
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<PackageData>) in
                handler(result.transform(with: {$0.packages}))
        }
    }
    
    func getReservations(of client: Client, handler: @escaping (ApiResult<[Reservation]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getStudentReservations")
        let parameters: Parameters = ["id": client.id, "reservationFor": client.type.rawValue]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ReservationData>) in
                handler(result.transform(with: {$0.reservations}))
        }
    }
    
    func getNextClasses(of client: Client, handler: @escaping (ApiResult<[Class]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getNextClasses")
        let parameters: Parameters = ["id": client.id, "reservationFor": client.type.rawValue]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ClassData>) in
                handler(result.transform(with: {$0.classes}))
        }
    }
    
    func updateAddress(_ address: String, forUserWithId userId: Int, handler: @escaping (ApiResult<Client>) -> Void) {
        let url = baseUrl.appendingPathComponent("updateAddress")
        let parameters: Parameters = ["id": userId, "address": address]
        let _ = self.session
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: URLEncoding.httpBody,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<UserData>) in
                switch result {
                case .success(let data):
                    handler(.success(data: data.client))
                case .failure(let error):
                    handler(.failure(error: error))
                }
        }
    }
    
    func registerClient(_ client: Client, handler: @escaping (ApiResult<Client>) -> Void) {
        let url = baseUrl.appendingPathComponent("registerClient")
        let _ = self.session.upload(multipartFormData: { (form) in
            client.encode(to: form)
        }, to: url) { (result) in
            switch result {
            case .success(let request, _, _):
                let _ = request.responseDecodable { (result: ApiResult<LoginData>) in
                    switch result {
                    case .success(let data):
                        self.createAdapter(accessToken: data.token, refreshToken: "")
                        self.user = data.client
                        handler(.success(data: data.client))
                    case .failure(let error):
                        handler(.failure(error: error))
                    }
                }
            case .failure(let error):
                handler(.failure(error: error))
            }
        }
    }
    
    func updateProfile(_ client: Client, handler: @escaping (ApiResult<Client>) -> Void) {
        let url = baseUrl.appendingPathComponent("updateClient")
        let _ = self.session.upload(multipartFormData: { (form) in
            client.encode(to: form)
        }, to: url) { (result) in
            switch result {
            case .success(let request, _, _):
                let _ = request.responseDecodable { (result: ApiResult<UserData>) in
                    switch result {
                    case .success(let data):
                        self.user = data.client
                        handler(.success(data: data.client))
                    case .failure(let error):
                        handler(.failure(error: error))
                    }
                }
            case .failure(let error):
                handler(.failure(error: error))
            }
        }
    }
    
    func registerSubaccount(_ client: Client, handler: @escaping (ApiResult<Client>) -> Void) {
        let url = baseUrl.appendingPathComponent("registerSubcuenta")
        let _ = self.session.upload(multipartFormData: { (form) in
            client.encode(to: form)
        }, to: url) { (result) in
            switch result {
            case .success(let request, _, _):
                let _ = request.responseDecodable { (result: ApiResult<UserData>) in
                    handler(result.transform(with: {$0.client}))
                }
            case .failure(let error):
                handler(.failure(error: error))
            }
        }
    }
    
    func sendResetCode(toEmail email: String, handler: @escaping (ApiResult<Void>) -> Void) {
        let url = baseUrl.appendingPathComponent("password/email")
        let parameters = ["email": email]
        let _ = self.session
            .request(url, method: .post, parameters: parameters,
                     encoding: URLEncoding.httpBody, headers: headers)
            .responseError(completionHandler: handler)
    }
    
    func resetPassword(forUser email: String, password: String, code: String, handler: @escaping (ApiResult<Void>) -> Void) {
        let url = baseUrl.appendingPathComponent("password/reset")
        let parameters = ["email": email, "token": code, "password": password, "password_confirmation": password]
        let _ = self.session
            .request(url, method: .post, parameters: parameters,
                     encoding: URLEncoding.httpBody, headers: headers)
            .responseError(completionHandler: handler)
    }
    
    func changePassword(to password: String, handler: @escaping (ApiResult<Void>) -> Void) {
        let url = baseUrl.appendingPathComponent("password/change")
        let parameters = ["password": password, "password_confirmation": password]
        let _ = self.session
            .request(url, method: .post, parameters: parameters,
                     encoding: URLEncoding.httpBody, headers: headers)
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
        var headers = self.headers
        headers["Content-Type"] = "application/json"
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
        var headers = self.headers
        headers["Content-Type"] = "application/json"
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

private struct FBLoginData: Decodable {
    var token: String?
    var client: Client?
    var facebookID: String?
    var name: String?
    var email: String?
}

private struct UserData: Decodable {
    var client: Client
}

private struct InstrumentData: Decodable {
    var instruments: [Instrument]
}

private struct LocationData: Decodable {
    var locations: [Location]
    
    private enum CodingKeys: String, CodingKey {
        case locations = "colonias"
    }
}

private struct PackageData: Decodable {
    var packages: [Package]
}

private struct ReservationData: Decodable {
    var reservations: [Reservation]
}

private struct ClassData: Decodable {
    var classes: [Class]
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


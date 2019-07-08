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
    
    private(set) var user: (User & NSCoding)? {
        didSet {
            if let user = self.user {
                self.keychain.set(user, forKey: "user")
            } else {
                self.keychain.removeObject(forKey: "user")
            }
        }
    }
    
    var currentClient: Client? {
        return user as? Client
    }
    
    var currentProfessor: Professor? {
        return user as? Professor
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
        self.user = self.keychain.object(forKey: "user") as? User & NSCoding
    }
    
    func createAdapter(accessToken: String, refreshToken: String) {
        let adapter = JWTAccessTokenAdapter(baseUrl: self.baseUrl, accessToken: accessToken, refreshToken: refreshToken)
        self.keychain.set(adapter, forKey: "adapter")
        self.session.adapter = adapter
        self.session.retrier = adapter
    }
    
    func signIn(withEmail userName: String, password: String,
                handler: @escaping (ApiResult<User>) -> Void) {
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
                    if let user = (data.client ?? data.professor) as? (NSCoding & User) {
                        self.user = user
                        handler(.success(data: user))
                    } else {
                        handler(.failure(error: AppError.unsupportedData))
                    }
                case .failure(let error):
                    handler(.failure(error: error))
                }
            }
    }
    
    func signIn(withFacebookToken accessToken: String,
                handler: @escaping (ApiResult<User>) -> Void) {
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
                    if let user = (data.client ?? data.professor) as? (NSCoding & User) {
                        self.user = user
                        handler(.success(data: user))
                    } else {
                        handler(.failure(error: AppError.unsupportedData))
                    }
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
        let url = baseUrl.appendingPathComponent("getClientToken")
        let headers = ["Accept": "text/plain"]
        let _ = self.session
            .request(url, method: .get,
                     encoding: URLEncoding.default,
                     headers: headers)
            .responseDecodable(completionHandler: handler)        
    }
    
    func performPaypalPayment(for package: Package, withToken token: String,
                              handler: @escaping (ApiResult<Void>) -> Void) {
        let url = baseUrl.appendingPathComponent("CreateTransaction")
        let parameters = ["payment_method_nonce": token]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseError(completionHandler: handler)
    }
    
    func getClient(handler: @escaping (ApiResult<Client>) -> Void) {
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
    
    func getUserInfo(handler: @escaping (ApiResult<User>) -> Void) {
        if self.user is Client {
            self.getClient { (result) in
                handler(result.transform(with: { $0 as User }))
            }
        } else if let professor = self.user as? Professor {
            self.getProfessor(withId: professor.id) { (result) in
                handler(result.transform(with: { $0 as User }))
            }
        } else {
            handler(.failure(error: AppError.invalidOperation))
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
        let parameters: Parameters = ["coloniaId": request.locationId ?? (self.user as? Client)?.locationId as Any,
                                      "instrumentId": request.instrument?.id as Any,
                                      "month": month]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<[DateWrapper]>) in
                handler(result.transform(with: {$0.compactMap({$0.date})}))
        }
    }
    
    func getAvailableProfessors(for request: ReservationRequest, inDay date: Date, handler: @escaping (ApiResult<[Professor]>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        
        let url = baseUrl.appendingPathComponent("getAvailableProfesorsOnDate")
        let parameters: Parameters = ["coloniaId": request.locationId ?? (self.user as? Client)?.locationId as Any,
                                      "instrumentId": request.instrument?.id as Any,
                                      "classDate": dateStr]
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
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFormatter.string(from: date)
        
        let url = baseUrl.appendingPathComponent("getAvailableProfesors")
        let parameters: Parameters = ["coloniaId": request.locationId ?? (self.user as? Client)?.locationId as Any,
                                      "instrumentId": request.instrument?.id as Any,
                                      "classDate": dateStr]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable(completionHandler: handler)
    }
    
    func getProfessor(withId id: Int, handler: @escaping (ApiResult<Professor>) -> Void) {
        let url = baseUrl.appendingPathComponent("getProfesorsData")
        let parameters: Parameters = ["profesorId": id]
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
                        if let client = data.client {
                            self.user = client
                            handler(.success(data: client))
                        } else {
                            handler(.failure(error: AppError.unsupportedData))
                        }
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
        /*
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
        }*/
        self.post(client, to: url) { (result: ApiResult<SubaccountData>) in
            handler(result.transform(with: { data in
                if let client = self.user as? Client {
                    client.subaccounts?.append(data.subaccount)
                }
                return data.subaccount
            }))
        }
    }
    
    func updateSubaccount(_ client: Client, handler: @escaping (ApiResult<Client>) -> Void) {
        let url = baseUrl.appendingPathComponent("updateSubcuenta")
        /*
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
        }*/
        self.post(client, to: url) { (result: ApiResult<SubaccountData2>) in
            handler(result.transform(with: { data in
                if let client = self.user as? Client, let index = client.subaccounts?.firstIndex(where: {$0.id == data.subaccount.id}) {
                    client.subaccounts?[index] = data.subaccount
                }
                return data.subaccount
            }))
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
                         handler: @escaping (ApiResult<Reservation>) -> Void) {
        var request = request
        request.locationId = request.locationId ?? (self.user as? Client)?.locationId
        request.address = request.address ?? (self.user as? Client)?.address
        let url = baseUrl.appendingPathComponent("classReservation")
        self.post(request, to: url, handler: handler)
    }
}

private struct LoginData: Decodable {
    var token: String
    var client: Client?
    var professor: Professor?
    
    private enum CodingKeys: String, CodingKey {
        case token
        case client
        case professor = "profesor"
    }
}

private struct FBLoginData: Decodable {
    var token: String?
    var client: Client?
    var facebookID: String?
    var name: String?
    var email: String?
    var professor: Professor?
    
    private enum CodingKeys: String, CodingKey {
        case token
        case client
        case facebookID
        case name
        case email
        case professor = "profesor"
    }
}

private struct UserData: Decodable {
    var client: Client
}

private struct SubaccountData: Decodable {
    var subaccount: Client
    
    private enum CodingKeys: String, CodingKey {
        case subaccount = "subcuenta"
    }
}

private struct SubaccountData2: Decodable {
    var subaccount: Client
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

private struct DateWrapper: Decodable {
    var date: Date
    
    enum CodingKeys: String, CodingKey {
        case date = "class_date_time"
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


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
        if self.session.adapter != nil {
            let url = baseUrl.appendingPathComponent("logout")
            let _ = self.session
                .request(url, method: .get,
                         encoding: URLEncoding.default,
                         headers: self.headers)
        }
        self.session.adapter = nil
        self.session.retrier = nil
        self.user = nil
        self.keychain.removeObject(forKey: "adapter")
    }
    
    func getStudent(for reservation: ReservationRequest) -> Student? {
        guard let studentType = reservation.studentType else { return nil }
        switch studentType {
        case .account:
            return self.currentClient
        default:
            return self.currentClient?.subaccounts?.first(where: {$0.id == reservation.studentId})
        }
    }
    
    func getTermsAndConditions(handler: @escaping (ApiResult<String>) -> Void) {
        let url = baseUrl.appendingPathComponent("getTermsAndConditions")
        let _ = self.session
            .request(url, method: .get,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<TermsData>) in
                handler(result.transform(with: {$0.terms}))
        }
    }
    
    func replyTermsAndConditions(accepted: Bool, handler: @escaping (ApiResult<Void>) -> Void) {
        let url = baseUrl.appendingPathComponent("responseTermsAndConditions")
        let parameters: Parameters = ["response": accepted]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseError { [weak self] result in
                switch result {
                case .success(_):
                    self?.user?.acceptedTermsAndConditions = accepted
                default:
                    break
                }
                handler(result)
        }
    }
    
    func getClientCredits(handler: @escaping (ApiResult<Int>) -> Void) {
        let url = baseUrl.appendingPathComponent("getClientCredits")
        let _ = self.session
            .request(url, method: .get,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<CreditData>) in
                handler(result.transform(with: {Int($0.credit) ?? -1}))
        }
    }
    
    func getPaypalToken(handler: @escaping (ApiResult<String>) -> Void) {
        let url = baseUrl.appendingPathComponent("getClientToken")
        let _ = self.session
            .request(url, method: .get,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable(completionHandler: handler)        
    }
    
    func performPaypalPayment(for package: Package, withToken token: String,
                              handler: @escaping (ApiResult<Void>) -> Void) {
        let url = baseUrl.appendingPathComponent("CreateTransaction")
        let parameters: Parameters = ["nonce": token, "packageId": package.id]
        let _ = self.session
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: URLEncoding.httpBody,
                     headers: self.headers)
            .responseError(completionHandler: handler)
    }
    
    func getClient(withId userId: Int, handler: @escaping (ApiResult<Client>) -> Void) {
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
                    if self.currentClient?.id == userId {
                        self.user = data.client
                    }
                    handler(.success(data: data.client))
                case .failure(let error):
                    handler(.failure(error: error))
                }
        }
    }
    
    func getUserInfo(handler: @escaping (ApiResult<User>) -> Void) {
        if let client = self.user as? Client {
            self.getClient(withId: client.id) { (result) in
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
    
    func getInstruments(of student: Student, handler: @escaping (ApiResult<[Instrument]>) -> Void) {
        var url: URL
        var parameters: Parameters
        if student is Client
        {
            url = baseUrl.appendingPathComponent("getClientInstruments")
            parameters = ["clientId": student.id]
        } else {
            url = baseUrl.appendingPathComponent("getSubaccountInstruments")
            parameters = ["subaccountId": student.id]
        }
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
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
    
    func getLocations(at address: String, handler: @escaping (ApiResult<Location>) -> Void) {
        let url = baseUrl.appendingPathComponent("getSublocality")
        let parameters: Parameters = ["address": address]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<LocationData2>) in
                handler(result.transform(with: {$0.location}))
        }
    }
    
    func getAvailableDays(for request: ReservationRequest, inMonth month: Int, handler: @escaping (ApiResult<[Date]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getAvailableClassOnMonth")
        let parameters: Parameters = ["coloniaId": request.locationId ?? self.getStudent(for: request)?.locationId as Any,
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
        dateFormatter.locale = Locale(identifier: "en-US")
        let dateStr = dateFormatter.string(from: date)
        
        let url = baseUrl.appendingPathComponent("getAvailableProfesorsOnDate")
        let parameters: Parameters = ["coloniaId": request.locationId ?? self.getStudent(for: request)?.locationId as Any,
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
        dateFormatter.locale = Locale(identifier: "en-US")
        let dateStr = dateFormatter.string(from: date)
        
        let url = baseUrl.appendingPathComponent("getAvailableProfesors")
        let parameters: Parameters = ["coloniaId": request.locationId ?? self.getStudent(for: request)?.locationId as Any,
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
            .responseDecodable { (result: ApiResult<Professor>) in
                switch result {
                case .success(let professor) where professor.id == self.currentProfessor?.id :
                    self.user = professor
                default:
                    break
                }
                handler(result)
        }
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
    
    func getReservations(of client: Student, handler: @escaping (ApiResult<[Reservation]>) -> Void) {
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
    
    func getReservations(of professor: Professor, handler: @escaping (ApiResult<[Reservation]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getProfesorReservations")
        let parameters: Parameters = ["id": professor.id]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ReservationData>) in
                handler(result.transform(with: {$0.reservations}))
        }
    }
    
    func getReservations(of user: User, handler: @escaping (ApiResult<[Reservation]>) -> Void) {
        switch user {
        case let client as Client:
            getReservations(of: client as Student, handler: handler)
        case let professor as Professor:
            getReservations(of: professor, handler: handler)
        default:
            handler(.failure(error: AppError.invalidOperation))
        }
    }
    
    func getNextClasses(ofUser user: User, handler: @escaping (ApiResult<[Class]>) -> Void) {
        switch user {
        case let client as Client:
            getNextClasses(of: client, handler: handler)
        case let professor as Professor:
            getNextClasses(of: professor, handler: handler)
        default:
            handler(.failure(error: AppError.unexpected))
        }
    }
    
    func getNextClasses(of client: Client, handler: @escaping (ApiResult<[Class]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getNextClasses")
        let parameters: Parameters = ["id": client.id]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ClassData>) in
                handler(result.transform(with: {$0.classes}))
        }
    }
    
    func getNextGuestClasses(handler: @escaping (ApiResult<[Class]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getNextClasses")
        let parameters: Parameters = ["id": currentClient?.id ?? 0, "reservationFor": StudentType.guest.rawValue]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ClassData>) in
                handler(result.transform(with: {$0.classes}))
        }
    }
    
    func getNextClasses(of professor: Professor, reservedOnly: Bool = false, handler: @escaping (ApiResult<[Class]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getProfesorNextClasses")
        var parameters: Parameters = ["id": professor.id]
        if reservedOnly {
            parameters["onlyClassScheduled"] = "true"
        }
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ClassData>) in
                handler(result.transform(with: {$0.classes}))
        }
    }
    
    func getNextReservations(of professor: Professor, handler: @escaping (ApiResult<[Reservation]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getProfesorReservations")
        let parameters: Parameters = ["id": professor.id, "next": "true"]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ReservationData>) in
                handler(result.transform(with: {$0.reservations}))
        }
    }
    
    func getClass(withId classId: Int, handler: @escaping (ApiResult<Class>) -> Void) {
        let url = baseUrl.appendingPathComponent("class").appendingPathComponent(classId.description)
        let _ = self.session
            .request(url, method: .get,
                     headers: self.headers)
            .responseDecodable(completionHandler: handler)
    }
    
    func getNextReservations(of student: Student, handler: @escaping (ApiResult<[Reservation]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getStudentReservations")
        let parameters: Parameters = ["id": student.id, "reservationFor": student.type.rawValue, "next": "true"]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ReservationData>) in
                handler(result.transform(with: {
                    $0.reservations                    
                }))
        }
    }
    
    func getNextGuestReservations(handler: @escaping (ApiResult<[Reservation]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getStudentReservations")
        let parameters: Parameters = ["id": currentClient?.id ?? 0, "reservationFor": StudentType.guest.rawValue, "next": "true"]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ReservationData>) in
                handler(result.transform(with: {
                    $0.reservations
                }))
        }
    }
    
    func getNextReservations(relatedTo client: Client, handler: @escaping (ApiResult<[Reservation]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getStudentReservations")
        let parameters: Parameters = ["id": client.id, "next": "true"]
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ReservationData>) in
                handler(result.transform(with: {
                    $0.reservations
                }))
        }
    }
    
    func getNextReservations(ofUser user: User, handler: @escaping (ApiResult<[Reservation]>) -> Void) {
        switch user {
        case let client as Client:
            getNextReservations(relatedTo: client, handler: handler)
        case let professor as Professor:
            getNextReservations(of: professor, handler: handler)
        default:
            handler(.failure(error: AppError.invalidOperation))
        }
    }
    
    func getMessages(from reservation: Reservation, since: Date? = nil, handler: @escaping (ApiResult<[Message]>) -> Void) {
        let url = baseUrl.appendingPathComponent("getLogHistory")
        var parameters: Parameters = ["reservaId": reservation.id]
        if let date = since {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en-US")
            parameters["since"] =  formatter.string(from: date)
        }
        let _ = self.session
            .request(url, method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<MessageData>) in
                handler(result.transform(with: {$0.logs}))
        }
    }
    
    func sendMessage(_ message: String, for reservation: Reservation, handler: @escaping (ApiResult<Message>) -> Void) {
        let url = baseUrl.appendingPathComponent("insertLog")
        let parameters: Parameters = ["reservaId": reservation.id, "logFor": StudentType.account.rawValue, "message": message]
        let _ = self.session
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: URLEncoding.httpBody,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<MessageData2>) in
                handler(result.transform(with: {$0.log}))
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
    
    func registerUser(_ user: User, handler: @escaping (ApiResult<User>) -> Void) {
        switch user {
        case let client as Client:
            self.registerClient(client) { result in
                handler(result.transform(with: {$0 as User}))
            }
        case let professor as Professor:
            self.registerProfessor(professor) { result in
                handler(result.transform(with: {$0 as User}))
            }
        default:
            handler(.failure(error: AppError.invalidOperation))
        }
    }
    
    func updateUser(_ user: User, handler: @escaping (ApiResult<User>) -> Void) {
        switch user {
        case let client as Client:
            self.updateProfile(client) { result in
                handler(result.transform(with: {$0 as User}))
            }
        case let professor as Professor:
            self.updateProfile(professor) { result in
                handler(result.transform(with: {$0 as User}))
            }
        default:
            handler(.failure(error: AppError.invalidOperation))
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
                            client.subaccounts = client.subaccounts ?? []
                            client.nextReservations = client.nextReservations ?? []
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
                        handler(.success(data: Client(copy: data.client)))
                    case .failure(let error):
                        handler(.failure(error: error))
                    }
                }
            case .failure(let error):
                handler(.failure(error: error))
            }
        }
    }
    
    func registerProfessor(_ professor: Professor, password: String? = nil, handler: @escaping (ApiResult<Professor>) -> Void) {
        let url = baseUrl.appendingPathComponent("registerProfesors")
        let _ = self.session.upload(multipartFormData: { (form) in
            professor.encode(to: form)
            if let password = password {
                form.encode(password, withName: "password")
                form.encode(password, withName: "password_confirmation")
            }
        }, to: url) { (result) in
            switch result {
            case .success(let request, _, _):
                let _ = request.responseDecodable { (result: ApiResult<LoginData>) in
                    switch result {
                    case .success(let data):
                        if let professor = data.professor {
                            professor.locations = professor.locations ?? []
                            professor.classes = professor.classes ?? []
                            self.user = professor
                            handler(.success(data: professor))
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
    
    func updateProfile(_ professor: Professor, password: String? = nil, handler: @escaping (ApiResult<Professor>) -> Void) {
        var url = URLComponents(url: baseUrl.appendingPathComponent("getProfesorsData"), resolvingAgainstBaseURL: false)!
        url.queryItems = [URLQueryItem(name: "profesorId", value: professor.id.description)]
        let _ = self.session.upload(multipartFormData: { (form) in
            professor.encode(to: form)
            if let password = password {
                form.encode(password, withName: "password")
                form.encode(password, withName: "password_confirmation")
            }
        }, to: try! url.asURL()) { (result) in
            switch result {
            case .success(let request, _, _):
                let _ = request.responseDecodable { (result: ApiResult<Professor>) in
                    switch result {
                    case .success(let data):
                        self.user = data
                        handler(.success(data: Professor(copy: data)))
                    case .failure(let error):
                        handler(.failure(error: error))
                    }
                }
            case .failure(let error):
                handler(.failure(error: error))
            }
        }
    }
    
    func registerSubaccount(_ subaccount: Subaccount, handler: @escaping (ApiResult<Subaccount>) -> Void) {
        let url = baseUrl.appendingPathComponent("registerSubcuenta")
        self.post(subaccount, to: url) { (result: ApiResult<SubaccountData>) in
            handler(result.transform(with: { data in
                if let client = self.user as? Client {
                    client.subaccounts?.append(data.subaccount)
                }
                return data.subaccount
            }))
        }
    }
    
    func updateSubaccount(_ subaccount: Subaccount, handler: @escaping (ApiResult<Subaccount>) -> Void) {
        let url = baseUrl.appendingPathComponent("updateSubcuenta")
        self.post(subaccount, to: url) { (result: ApiResult<SubaccountData2>) in
            handler(result.transform(with: { data in
                if let client = self.user as? Client, let index = client.subaccounts?.firstIndex(where: {$0.id == data.subaccount.id}) {
                    client.subaccounts?[index] = data.subaccount
                }
                return data.subaccount
            }))
        }
    }
    
    func deleteSubaccount(_ subaccount: Subaccount, handler: @escaping (ApiResult<Void>) -> Void) {
        let url = baseUrl.appendingPathComponent("removeSubcuenta")
        let parameters = ["subcuentaId": subaccount.id]
        let _ = self.session
            .request(url, method: .post, parameters: parameters,
                     encoding: URLEncoding.httpBody, headers: headers)
            .responseError { (result) in
                handler(result.transform(with: {
                    if let client = self.user as? Client {
                        client.subaccounts?.removeAll(where: {$0.id == subaccount.id})
                    }
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
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en-US")
            encoder.dateEncodingStrategy = .formatted(formatter)
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
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en-US")
            encoder.dateEncodingStrategy = .formatted(formatter)
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
        request.locationId = request.locationId ?? self.getStudent(for: request)?.locationId
        request.address = request.address ?? self.getStudent(for: request)?.address
        request.studentId = request.studentId ?? self.currentClient?.id
        let url = baseUrl.appendingPathComponent("classReservation1")
        self.post(request, to: url) { (result: ApiResult<ReservationData2>) in
            handler(result.transform(with: {
                self.currentClient?.nextReservations?.append($0.reservation)
                if let credits = self.currentClient?.credits {
                    self.currentClient?.credits = credits - 1
                }
                return $0.reservation
            }))
        }
    }
    
    func cancelReservation(_ reservation: Reservation, handler: @escaping (ApiResult<Reservation>) -> Void) {
        let url = baseUrl.appendingPathComponent("cancelReservation")
        let parameters: Parameters = ["classId": reservation.classes?.id,
                                     "id": reservation.subaccountId ?? reservation.clientId,
                                     "reservationFor": reservation.studentType.rawValue]
        let _ = self.session.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseDecodable() {
            (result: ApiResult<ReservationData2>) in
            handler(result.transform(with: { data in
                self.currentClient?.nextReservations?.removeAll(where: {$0.id == data.reservation.id})
                if let credits = self.currentClient?.credits {
                    self.currentClient?.credits = credits + 1
                }
                return data.reservation
            }))
        }
    }
    
    func createClass(_ request: ClassRequest,
                     handler: @escaping (ApiResult<Class>) -> Void) {
        var request = request
        request.professorId = request.professorId ?? self.currentProfessor?.id
        let url = baseUrl.appendingPathComponent("createClass")
        self.post(request, to: url) { (result: ApiResult<Class>) in
            handler(result.transform(with: {
                self.currentProfessor?.classes?.append($0)
                return $0
            }))
        }
    }
    
    func cancelClass(_ reservation: Class, handler: @escaping (ApiResult<Class>) -> Void) {
        guard let professorId = self.currentProfessor?.id else {
            return handler(.failure(error: AppError.invalidOperation))
        }
        let url = baseUrl.appendingPathComponent("cancelClass")
        let parameters: Parameters = ["id": professorId, "classId": reservation.id]
        let _ = self.session
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: URLEncoding.httpBody,
                     headers: self.headers)
            .responseDecodable { (result: ApiResult<ClassData2>) in
                handler(result.transform(with: { data in
                    self.currentProfessor?.classes?.removeAll(where: {$0.id == data.classes.id})
                    return data.classes
                }))
        }
    }
    
    func notifyMessageRead(_ message: Message, handler: @escaping (ApiResult<Message>) -> Void) {
        let url = baseUrl.appendingPathComponent("markasreaded")
        let parameters = ["messageId": message.id]
        let _ = self.session
            .request(url, method: .get, parameters: parameters,
                     encoding: URLEncoding.default, headers: headers)
            .responseDecodable(completionHandler: handler)
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

private struct ProfessorData: Decodable {
    var professor: Professor
    
    private enum CodingKeys: String, CodingKey {
        case professor = "profesor"
    }
}

private struct SubaccountData: Decodable {
    var subaccount: Subaccount
    
    private enum CodingKeys: String, CodingKey {
        case subaccount = "subcuenta"
    }
}

private struct SubaccountData2: Decodable {
    var subaccount: Subaccount
}

private struct TermsData: Decodable {
    var terms: String
}

private struct CreditData: Decodable {
    var credit: String
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

private struct LocationData2: Decodable {
    var location: Location
    
    private enum CodingKeys: String, CodingKey {
        case location = "colonia"
    }
}

private struct PackageData: Decodable {
    var packages: [Package]
}

private struct ReservationData: Decodable {
    var reservations: [Reservation]
}

private struct ReservationData2: Decodable {
    var reservation: Reservation
}

private struct ClassData: Decodable {
    var classes: [Class]
}

private struct ClassData2: Decodable {
    var classes: Class
    
    enum CodingKeys: String, CodingKey {
        case classes = "class"
    }
}

private struct DateWrapper: Decodable {
    var date: Date
    
    enum CodingKeys: String, CodingKey {
        case date = "class_date_time"
    }
}

private struct MessageData: Decodable {
    var logs: [Message]
}

private struct MessageData2: Decodable {
    var log: Message
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


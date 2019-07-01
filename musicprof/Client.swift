//
//  User.swift
//  musicprof
//
//  Created by John Doe on 6/22/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import Alamofire
import MobileCoreServices


class Client: NSObject, Decodable, NSCoding, Student {
    var id: Int
    var userId: Int
    var name: String
    var email: String?
    var phone: String?
    var address: String?
    var locationId: Int?
    var avatarUrl: URL?
    var facebookId: String?
    var instruments: [Instrument]?
    var subaccounts: [Client]?
    var nextReservations: [Reservation]?
    
    override init() {
        self.id = -1
        self.userId = -1
        self.name = "test"
        self.locationId = 409
        self.address = "test address"
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let user = container.contains(.user) ? try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user) : nil
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.id = try user?.decode(Int.self, forKey: .id) ?? container.decode(Int.self, forKey: .id)
        self.name = try (container.decodeIfPresent(String.self, forKey: .name)
            ?? user?.decodeIfPresent(String.self, forKey: .name))
            ?? ""
        self.email = try user?.decodeIfPresent(String.self, forKey: .email)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.locationId = try container.decodeIfPresent(Int.self, forKey: .locationId)
        let avatar = try user?.decodeIfPresent(String.self, forKey: .avatar)
        self.avatarUrl = avatar == nil ? nil : URL(string: avatar!)
        self.facebookId = try user?.decodeIfPresent(String.self, forKey: .facebookId)
        self.instruments = try container.decodeIfPresent([Instrument].self, forKey: .instruments)
        self.subaccounts = try container.decodeIfPresent([Client].self, forKey: .subaccounts)
        self.nextReservations = try container.decodeIfPresent([Reservation].self, forKey: .nextReservations)
    }
    
    required init?(coder: NSCoder) {
        self.id = coder.decodeInteger(forKey: UserKeys.id.rawValue)
        self.userId = self.id
        self.name = coder.decodeObject(forKey: UserKeys.name.rawValue) as? String ?? ""
        self.email = coder.decodeObject(forKey: UserKeys.email.rawValue) as? String
        self.phone = coder.decodeObject(forKey: CodingKeys.phone.rawValue) as? String
        self.address = coder.decodeObject(forKey: CodingKeys.address.rawValue) as? String
        self.locationId = coder.decodeObject(forKey: CodingKeys.locationId.rawValue) as? Int
        let avatar = coder.decodeObject(forKey: UserKeys.avatar.rawValue) as? String
        self.avatarUrl = avatar == nil ? nil : URL(string: avatar!)
        self.facebookId = coder.decodeObject(forKey: UserKeys.facebookId.rawValue) as? String
        self.instruments = nil
        self.subaccounts = nil
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: UserKeys.id.rawValue)
        coder.encode(self.name, forKey: UserKeys.name.rawValue)
        coder.encode(self.email, forKey: UserKeys.avatar.rawValue)
        coder.encode(self.phone, forKey: CodingKeys.phone.rawValue)
        coder.encode(self.address, forKey: CodingKeys.address.rawValue)
        coder.encode(self.locationId, forKey: CodingKeys.locationId.rawValue)
        coder.encode(self.avatarUrl?.absoluteURL, forKey: UserKeys.avatar.rawValue)
        coder.encode(self.facebookId, forKey: UserKeys.facebookId.rawValue)
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case userId = "users_id"
        case user
        case phone
        case name
        case address
        case locationId = "colonia_id"
        case instruments
        case subaccounts
        case nextReservations = "next_reservations"
    }
    
    fileprivate enum UserKeys: String, CodingKey {
        case id
        case name
        case email
        case avatar = "photo"
        case facebookId = "facebook_id"
    }
}

enum ClientType: Int {
    case account = 1
    case subaccount = 2
}

extension Client {
    var type: ClientType {
        return self.userId == self.id ? .account : .subaccount
    }
}

extension Client {
    private func encode(_ str: CustomStringConvertible, withName name: String, to form: MultipartFormData) {
        form.append(str.description.data(using: .utf8)!, withName: name)
    }
    
    private func encodeIfPresent(_ str: CustomStringConvertible?, withName name: String, to form: MultipartFormData) {
        guard let str = str else { return }
        form.append(str.description.data(using: .utf8)!, withName: name)
    }
    
    private func encodeValues<T: CustomStringConvertible>(_ values: [T]?, withName name: String, to form: MultipartFormData) {
        let values = values ?? []
        for i in 0 ..< values.count {
            self.encode(values[i], withName: "\(name)[]", to: form)
        }
    }
    
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        
        return "application/octet-stream"
    }
    
    func encode(to form: MultipartFormData) {
        if self.id >= 0 {
            self.encode(self.id, withName: UserKeys.id.rawValue, to: form)
        }
        if self.type == .subaccount {
            self.encode(self.userId, withName: "idCuenta", to: form)
        }
        self.encode(self.name, withName: CodingKeys.name.rawValue, to: form)
        self.encodeIfPresent(self.email, withName: UserKeys.email.rawValue, to: form)
        self.encodeIfPresent(self.phone, withName: CodingKeys.phone.rawValue, to: form)
        self.encodeIfPresent(self.address, withName: CodingKeys.address.rawValue, to: form)
        self.encodeIfPresent(self.locationId, withName: "coloniaId", to: form)
        self.encodeValues(self.instruments?.map({$0.id}), withName: CodingKeys.instruments.rawValue, to: form)
        self.encodeIfPresent(self.facebookId, withName: "facebookID", to: form)
        self.encode(1, withName: "paymentTypeId", to: form)
        if let avatarUrl = self.avatarUrl, avatarUrl.isFileURL {
            form.append(avatarUrl, withName: UserKeys.avatar.rawValue)
        }
    }
}

extension Client {
    func loadFromFB(completion: @escaping (Error?) -> Void) {
        guard FBSDKAccessToken.current() != nil else {
            return completion(AppError.invalidOperation)
        }
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start { (connection, result, error) -> Void in
            if let error = error {
                completion(error)
            } else if let dict = result as? [String : Any] {
                let picture = dict["picture"] as? [String: Any]
                var data = picture?["data"] as? [String : Any]
                let imageUrlString = data?["url"] as? String
                self.avatarUrl = imageUrlString == nil ? nil : URL(string: imageUrlString!)
                self.name = dict["name"] as? String ?? self.name
                self.email = dict["email"] as? String ?? self.email
                self.facebookId = (dict["id"] as? String)!
                completion(nil)
            } else {
                completion(AppError.unsupportedData)
            }
        }
    }
}

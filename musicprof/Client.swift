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


class Client: NSObject, Decodable, NSCoding, Student, User {
    var id: Int
    var userId: Int
    var name: String
    var email: String?
    var phone: String?
    var address: String?
    var locationId: Int?
    var location: Location?
    var avatarUrl: URL?
    var facebookId: String?
    var credits: Int?
    var instruments: [Instrument]?
    var subaccounts: [Subaccount]?
    var nextReservations: [Reservation]?
    
    var type: StudentType {
        return .account 
    }
    
    override init() {
        self.id = -1
        self.userId = -1
        self.name = ""
        super.init()
    }
    
    init(copy other: Client) {
        self.userId = other.userId
        self.id = other.id
        self.name = other.name
        self.email = other.email
        self.phone = other.phone
        self.address = other.address
        self.locationId = other.locationId
        self.avatarUrl = other.avatarUrl
        self.facebookId = other.facebookId
        self.location = other.location
        self.instruments = other.instruments
        self.subaccounts = other.subaccounts
        self.nextReservations = other.nextReservations
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let user = container.contains(.user) ? try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user) : nil
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.id = try user?.decode(Int.self, forKey: .id) ?? container.decode(Int.self, forKey: .id)
        self.name = try (user?.decodeIfPresent(String.self, forKey: .name)) ?? ""
        self.email = try user?.decodeIfPresent(String.self, forKey: .email)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.locationId = try container.decodeIfPresent(Int.self, forKey: .locationId)
        if self.locationId == 0 {
            self.locationId = nil
        }
        self.location = try container.decodeIfPresent(Location.self, forKey: .location)
        if let credits = try container.decodeIfPresent(Int.self, forKey: .credits) {
            self.credits = Int(credits)
        }
        let avatar = try user?.decodeIfPresent(String.self, forKey: .avatar)
        self.avatarUrl = avatar == nil ? nil : URL(string: avatar!)
        self.facebookId = try user?.decodeIfPresent(String.self, forKey: .facebookId)
        self.instruments = try container.decodeIfPresent([Instrument].self, forKey: .instruments)
        self.subaccounts = try container.decodeIfPresent([Subaccount].self, forKey: .subaccounts)
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
        case address
        case locationId = "colonia_id"
        case location = "colonia"
        case credits = "credit"
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

extension Client: MultiformEncodable {
    func encode(to form: MultipartFormData) {
        if self.id >= 0 {
            form.encode(self.id, withName: UserKeys.id.rawValue)
        }
        if self.type == .subaccount {
            form.encode(self.userId, withName: "idCuenta")
        }
        form.encode(self.name, withName: UserKeys.name.rawValue)
        form.encodeIfPresent(self.email, withName: UserKeys.email.rawValue)
        form.encodeIfPresent(self.phone, withName: CodingKeys.phone.rawValue)
        form.encodeIfPresent(self.address, withName: CodingKeys.address.rawValue)
        form.encodeIfPresent(self.locationId, withName: "coloniaId")
        form.encodeValues(self.instruments?.map({$0.id}), withName: CodingKeys.instruments.rawValue)
        form.encodeIfPresent(self.facebookId, withName: "facebookID")
        form.encode(1, withName: "paymentTypeId")
        if let avatarUrl = self.avatarUrl, avatarUrl.isFileURL {
            form.append(avatarUrl, withName: UserKeys.avatar.rawValue)
        }
    }
}

extension Client {
    override func isEqual(_ object: Any?) -> Bool {
        let lhs = self
        guard let rhs = object as? Client else { return false }
        return lhs.id == rhs.id && lhs.userId == rhs.userId &&
            lhs.name == rhs.name && lhs.email == rhs.email &&
            lhs.phone == rhs.phone &&
            lhs.address == rhs.address && lhs.locationId == rhs.locationId &&
            lhs.facebookId == rhs.facebookId && lhs.avatarUrl == rhs.avatarUrl &&
            Set(lhs.instruments ?? []) == Set(rhs.instruments ?? [])
    }
}

extension Client {
    func update(from other: Client, overwrite: Bool = false) {
        if overwrite {
            self.userId = other.userId < 0 ? self.userId : other.userId
            self.id = other.id < 0 ? self.id : other.id
            self.name = other.name.isEmpty ? self.name : other.name
            self.email = other.email ?? self.email
            self.phone = other.phone ?? self.phone
            self.address = other.address ?? self.address
            self.locationId = other.locationId ?? self.locationId
            self.avatarUrl = other.avatarUrl ?? self.avatarUrl
            self.facebookId = other.facebookId ?? self.facebookId
            self.instruments = other.instruments ?? self.instruments
            self.subaccounts = other.subaccounts ?? self.subaccounts
            self.nextReservations = other.nextReservations ?? self.nextReservations
        } else {
            self.userId = self.userId < 0 ? other.userId : self.userId
            self.id = self.id < 0 ? other.id : self.id
            self.name = self.name.isEmpty ? other.name : self.name
            self.email = self.email ?? other.email
            self.phone = self.phone ?? other.phone
            self.address = self.address ?? other.address
            self.locationId = self.locationId ?? other.locationId
            self.avatarUrl = self.avatarUrl ?? other.avatarUrl
            self.facebookId = self.facebookId ?? other.facebookId
            self.instruments = self.instruments ?? other.instruments
            self.subaccounts = self.subaccounts ?? other.subaccounts
            self.nextReservations = self.nextReservations ?? other.nextReservations
        }
    }
}

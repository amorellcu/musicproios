//
//  Professor.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

class Professor: Decodable {
    var id: Int
    var name: String
    var phone: String?
    var email: String?
    var address: String?
    var price: Float? = nil
    var avatarUrl: URL?
    var facebookId: String?
    
    var reservations: [Reservation]?
    var locations: [Location]?
    var instruments: [Instrument]?
    
    static let standard = Professor(id: 0, name: "Allan Buenfill Mejías")
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let user = container.contains(.user) ? try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user) : nil
        self.id = try user?.decode(Int.self, forKey: .id) ?? container.decode(Int.self, forKey: .id)
        self.name = try (container.decodeIfPresent(String.self, forKey: .name)
            ?? user?.decodeIfPresent(String.self, forKey: .name))
            ?? ""
        self.email = try user?.decodeIfPresent(String.self, forKey: .email)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        let avatar = try user?.decodeIfPresent(String.self, forKey: .avatar)
        self.avatarUrl = avatar == nil ? nil : URL(string: avatar!)
        self.facebookId = try user?.decodeIfPresent(String.self, forKey: .facebookId)
        self.instruments = try container.decodeIfPresent([Instrument].self, forKey: .instruments)
        self.locations = try container.decodeIfPresent([Location].self, forKey: .locations)
        self.reservations = try container.decodeIfPresent([Reservation].self, forKey: .reservations)
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case user
        case phone
        case name
        case address
        case locations = "colonias"
        case instruments
        case reservations = "classes"
    }
    
    fileprivate enum UserKeys: String, CodingKey {
        case id
        case name
        case email
        case avatar = "photo"
        case facebookId = "facebook_id"
    }
}

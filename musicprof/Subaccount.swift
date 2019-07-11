//
//  Subaccount.swift
//  musicprof
//
//  Created by John Doe on 7/11/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

class Subaccount: Decodable, Student {
    var id: Int = -1
    var userId: Int = -1
    var name: String = ""
    var phone: String?
    var address: String?
    var locationId: Int?
    var location: Location?
    var instruments: [Instrument]?
    
    var type: StudentType {
        return .subaccount
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case userId = "users_id"
        case phone
        case name
        case address
        case locationId = "colonia_id"
        case location = "colonia"
    }
    
    fileprivate enum EncodingKeys: String, CodingKey {
        case id
        case name
        case userId = "idCuenta"
        case address
        case instruments
    }
}

extension Subaccount: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        if self.id >= 0 {
            try container.encode(self.id, forKey: .id)
        } else {
            try container.encode(self.userId, forKey: .userId)
        }
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.address, forKey: .address)
        try container.encodeIfPresent(self.instruments?.map {$0.id}, forKey: .instruments)
    }
}

extension Subaccount: Equatable {
    static func == (lhs: Subaccount, rhs: Subaccount) -> Bool {
        return lhs.id == rhs.id && lhs.userId == rhs.userId &&
            lhs.name == rhs.name &&
            lhs.phone == rhs.phone &&
            lhs.address == rhs.address && lhs.locationId == rhs.locationId &&
            Set(lhs.instruments ?? []) == Set(rhs.instruments ?? [])
    }
}

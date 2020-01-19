//
//  Reservation.swift
//  musicprof
//
//  Created by John Doe on 7/3/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Reservation: Decodable {
    var id: Int
    var classId: Int
    var clientId: Int?
    var client: Client?
    var status: ReservationState
    var subaccountId: Int?
    var creditId: Int?
    var address: String?
    var classes: Class?
    var guestName: String?
    var guestEmail: String?
    var unreadMessages: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case classId = "class_id"
        case clientId = "client_id"
        case client
        case status = "reservation_status"
        case subaccountId = "subcuenta_id"
        case creditId = "credit_id"
        case address
        case classes
        case unreadMessages = "unreadedmessage"
        case guestName = "guest_name"
        case guestEmail = "guest_email"
    }
}

extension Reservation {
    var studentType: StudentType {
        if guestName != nil && guestEmail != nil {
            return .guest
        }
        if subaccountId != nil {
            return .subaccount
        }
        if clientId != nil {
            return .account
        }
        return .guest
    }
}

extension Reservation {
    init?(fromJSON json: [String:Any]) {
        guard let id = json[CodingKeys.id.rawValue] as? Int else { return nil }
        guard let classId = json[CodingKeys.classId.rawValue] as? Int else { return nil }
        let clientId = json[CodingKeys.clientId.rawValue] as? Int
        guard let status = ReservationState(rawValue: json[CodingKeys.status.rawValue] as? Int ?? 0) else { return nil }
        let subaccountId = json[CodingKeys.subaccountId.rawValue] as? Int
        let creditId = json[CodingKeys.creditId.rawValue] as? Int
        let address = json[CodingKeys.address.rawValue] as? String
        let unreadMessages = json[CodingKeys.unreadMessages.rawValue] as? Int
        let guestName = json[CodingKeys.guestName.rawValue] as? String
        let guestEmail = json[CodingKeys.guestEmail.rawValue] as? String
        self.init(id: id, classId: classId, clientId: clientId, client: nil,
                  status: status, subaccountId: subaccountId,
                  creditId: creditId, address: address, classes: nil,
                  guestName: guestName, guestEmail: guestEmail, unreadMessages: unreadMessages)
    }
}

enum ReservationState: Int, Decodable {
    case normal = 0
    case cancelled = 1
}

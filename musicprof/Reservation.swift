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
        if subaccountId != nil {
            return .subaccount
        }
        if clientId != nil {
            return .account
        }
        return .guest
    }
}

enum ReservationState: Int, Decodable {
    case normal = 0
    case cancelled = 1
}

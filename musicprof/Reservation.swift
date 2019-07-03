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
    var clientId: Int
    var status: Int
    var subaccountId: Int?
    var creditId: Int?
    var address: String?
    var classes: Class?
    
    enum CodingKeys: String, CodingKey {
        case id
        case classId = "class_id"
        case clientId = "client_id"
        case status = "reservation_status"
        case subaccountId = "subcuenta_id"
        case creditId = "credit_id"
        case address
        case classes
    }
}

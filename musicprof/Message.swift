//
//  Message.swift
//  musicprof
//
//  Created by John Doe on 7/10/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Message: Decodable {
    var id: Int
    var classId: Int?
    var clientId: Int?
    var subaccountId: Int?
    var professorId: Int?
    var text: String
    var date: Date?
    
    var source: MessageSource {
        if (clientId != nil || subaccountId != nil) && professorId == nil {
            return .client
        }
        if clientId == nil && subaccountId == nil && professorId != nil {
            return .professor
        }
        return .unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case classId = "class_id"
        case clientId = "client_id"
        case subaccountId = "subcuenta_id"
        case professorId = "profesor_id"
        case text = "message"
        case date = "log_date_time"
    }
}

enum MessageSource: String, Decodable {
    case client
    case professor
    case unknown
}

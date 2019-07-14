//
//  Reservation.swift
//  musicprof
//
//  Created by John Doe on 6/26/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Class: Decodable {
    var id: Int
    var date: Date
    var professor: Professor?
    var professorId: Int?
    var instrument: Instrument?
    var instrumentId: Int?
    var status: Int?
    var reservations: [Reservation]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date = "class_date_time"
        case professorId = "profesor_id"
        case professor = "profesor"
        case instrumentId = "instrument_id"
        case instrument
        case status = "class_status"
        case reservations
    }
}

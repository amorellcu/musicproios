//
//  Reservation.swift
//  musicprof
//
//  Created by John Doe on 6/26/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Reservation: Decodable {
    var id: Int
    var date: Date
    var professor: Professor?
    var professorId: Int?
    var instrument: Instrument?
    var instrumentId: Int?
    var status: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date = "class_date_time"
        case professorId = "profesor_id"
        case professor
        case instrumentId = "instrument_id"
        case instrument
        case status = "class_status"
    }
}

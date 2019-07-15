//
//  ClassRequest.swift
//  musicprof
//
//  Created by John Doe on 7/15/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct ClassRequest: Encodable {
    var date: Date?
    var professorId: Int?
    var instrument: Instrument?
    var instrumentId: Int?
    var calendar: Calendar?
    
    enum CodingKeys: String, CodingKey {
        case date = "class_date_time"
        case professorId = "profesor_id"
        case instrumentId = "instrument_id"
    }
}

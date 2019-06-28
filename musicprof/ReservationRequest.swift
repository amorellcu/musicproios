//
//  ReservationRequest.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct ReservationRequest {
    var date: Date?
    var professor: Professor?
    var instrument: Instrument?
    var studentId: Int?
    var locationId: Int?
    var studentNames: [String]?
    var address: String?
    var calendar: Calendar?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case date = "classDate"
        case proffessor = "profesorId"
        case instrument = "instrumentId"
        case client = "reservationFor"
        case address
    }
}

extension ReservationRequest: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let date = self.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            dateFormatter.calendar = Calendar.current
            
            try container.encodeIfPresent(dateFormatter.string(from: date), forKey: .date)
        }
        try container.encodeIfPresent(self.professor?.id, forKey: .proffessor)
        try container.encodeIfPresent(self.instrument?.id, forKey: .instrument)
        try container.encodeIfPresent(self.studentId, forKey: .client)
        try container.encodeIfPresent(self.address, forKey: .address)
    }
}

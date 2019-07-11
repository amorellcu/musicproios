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
    var studentType: StudentType?
    var locationId: Int?
    var studentNames: [String]?
    var address: String?
    var calendar: Calendar?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case studentId = "id"
        case date = "classDate"
        case proffessor = "profesorId"
        case instrument = "instrumentId"
        case studentType = "reservationFor"
        case address
    }
}

extension ReservationRequest: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let date = self.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.calendar = Calendar.current
            
            try container.encodeIfPresent(dateFormatter.string(from: date), forKey: .date)
        }
        try container.encodeIfPresent(self.professor?.id, forKey: .proffessor)
        try container.encodeIfPresent(self.instrument?.id, forKey: .instrument)
        try container.encodeIfPresent(self.studentId, forKey: .studentId)
        try container.encodeIfPresent(self.studentType?.rawValue, forKey: .studentType)
        try container.encodeIfPresent(self.address, forKey: .address)
    }
}

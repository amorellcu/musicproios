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
    var reservationId: Int?
    var clientId: Int?
    var subaccountId: Int?
    var professorId: Int?
    var text: String
    var date: Date?
    var reservation: Reservation?
    fileprivate var readInt: Int?
    
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
        case reservationId = "reservation_id"
        case clientId = "client_id"
        case subaccountId = "subcuenta_id"
        case professorId = "profesor_id"
        case text = "message"
        case date = "log_date_time"
        case readInt = "readed"
        case reservation
    }
}

enum MessageSource: String, Decodable {
    case client
    case professor
    case unknown
}

extension Message {
    var wasRead: Bool? {
        get {
            guard let readInt = self.readInt else { return nil }
            return readInt != 0
        }
        set {
            if let value = newValue {
                self.readInt = value ? 1 : 0
            } else {
                self.readInt = nil
            }
        }
    }
    
    init?(fromJSON json: [String:Any]) {
        guard let id = json[CodingKeys.id.rawValue] as? Int, let text = json[CodingKeys.text.rawValue] as? String else { return nil }
        let reservationId = json[CodingKeys.reservationId.rawValue] as? Int
        let clientId = json[CodingKeys.clientId.rawValue] as? Int
        let subaccountId = json[CodingKeys.subaccountId.rawValue] as? Int
        let professorId = json[CodingKeys.professorId.rawValue] as? Int
        var date: Date? = nil
        if let dateStr = json[CodingKeys.date.rawValue] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.calendar = Calendar.current
            date = dateFormatter.date(from: dateStr)
        }
        var reservation: Reservation? = nil
        if let json = json[CodingKeys.reservation.rawValue] as? [String: Any] {
            reservation = Reservation(fromJSON: json)
        }
        self.init(id: id, reservationId: reservationId,
                  clientId: clientId, subaccountId: subaccountId, professorId: professorId,
                  text: text, date: date, reservation: reservation, readInt: 0)
    }
}

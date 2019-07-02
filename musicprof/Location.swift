//
//  Location.swift
//  musicprof
//
//  Created by John Doe on 6/25/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Location: Decodable {
    var id: Int
    var zone: String
    var state: String?
    var stateId: Int?
    var municipality: String?
    var city: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case stateId = "idEstado"
        case zone = "asentamiento"
        case state = "estado"
        case municipality = "municipio"
        case city = "ciudad"
    }
}

extension Location: CustomStringConvertible {
    var description: String {
        let components = [self.state, self.city]
        return components.compactMap({$0}).joined(separator: ", ")
    }
}

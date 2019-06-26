//
//  Instrument.swift
//  musicprof
//
//  Created by John Doe on 6/12/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Instrument: Decodable {
    var id: Int
    var name: String
    var icon: String
    
    init(id: Int, name: String, icon: String) {
        self.name = name
        self.icon = icon
        self.id = id
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon = "icono"
    }
}

extension Instrument {
    var iconUrl: URL? {
        return URL(string: self.icon)
    }
}

extension Instrument: Equatable, Hashable {
    static func == (lhs: Instrument, rhs: Instrument) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return self.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

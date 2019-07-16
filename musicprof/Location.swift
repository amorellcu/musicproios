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
    var name: String
    var zone: String?
    var state: String?
    var stateId: Int?
    var municipality: String?
    var city: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.zone = try container.decodeIfPresent(String.self, forKey: .zone)
        self.stateId = try container.decodeIfPresent(Int.self, forKey: .stateId)
        self.municipality = try container.decodeIfPresent(String.self, forKey: .municipality)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        guard container.contains(.state) else { return }
        if let state = try? container.decode(String.self, forKey: .state) {
            self.state = state
        } else {
            let stateContainer = try container.nestedContainer(keyedBy: StateCodingKeys.self, forKey: .state)
            self.state = try stateContainer.decodeIfPresent(String.self, forKey: .name)
        }
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case stateId = "idEstado"
        case zone = "zona"
        case name = "asentamiento"
        case state = "estado"
        case municipality = "municipio"
        case city = "ciudad"
    }
    
    private enum StateCodingKeys: String, CodingKey {
        case id
        case name = "estado"
        case price
    }
}

extension Location: CustomStringConvertible {
    var description: String {
        return self.name
    }
}

extension Location: Equatable, Hashable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return self.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}


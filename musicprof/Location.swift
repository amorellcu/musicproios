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
    
    init(id: Int, name: String, icon: String) {
        self.name = name
        self.id = id
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case name = "asentamiento"
    }
}

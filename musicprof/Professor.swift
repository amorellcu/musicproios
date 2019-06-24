//
//  Professor.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Professor: Decodable {
    var id: Int
    var name: String
    var price: Float?
    var icon: String    
}

extension Professor {
    var iconUrl: URL? {
        return URL(string: self.icon)
    }
}

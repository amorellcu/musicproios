//
//  Message.swift
//  musicprof
//
//  Created by John Doe on 7/10/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Message: Decodable {
    var text: String
    var source: MessageSource
    
    enum CodingKeys: String, CodingKey {
        case text
        case source
    }
}

enum MessageSource: String, Decodable {
    case local
    case remote
}

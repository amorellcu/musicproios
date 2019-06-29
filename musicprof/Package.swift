//
//  Package.swift
//  musicprof
//
//  Created by John Doe on 6/29/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Package: Decodable {
    var id: Int
    var name: String
    var quantity: Int
    var priceStr: String
    var expiresOn: Int?
    var stateId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity = "classes_qty"
        case priceStr = "price"
        case expiresOn = "expires_on"
        case stateId = "stateId"
    }
}

extension Package {
    var price: Float? {
        return Float(self.priceStr)
    }
}

//
//  Guest.swift
//  musicprof
//
//  Created by John Doe on 12/27/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

struct Guest: Student {
    var id: Int {
        return 0
    }
    var userId: Int = 0
    var name: String
    var email: String
    var address: String?
    var locationId: Int?
    var instruments: [Instrument]? {
        return nil
    }
    var type: StudentType {
        return .guest
    }
}

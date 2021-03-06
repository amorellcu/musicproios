//
//  Student.swift
//  musicprof
//
//  Created by John Doe on 6/27/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

protocol Student {
    var id: Int { get }
    var userId: Int { get }
    var name: String { get }
    var address: String? { get }
    var locationId: Int? { get }
    var instruments: [Instrument]? { get }
    var type: StudentType { get }
}

enum StudentType: Int, Codable {
    case account = 1
    case subaccount = 2
    case guest = 3
}

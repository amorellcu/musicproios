//
//  User.swift
//  musicprof
//
//  Created by John Doe on 7/8/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

protocol User: class {
    var id: Int { get }
    var name: String { get }
    var email: String? { get }
    var phone: String? { get }
    var address: String? { get }
    var avatarUrl: URL? { get }
}

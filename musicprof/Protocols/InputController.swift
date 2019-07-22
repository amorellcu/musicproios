//
//  InputController.swift
//  musicprof
//
//  Created by Jon Doe on 7/22/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

protocol InputController: class {
    func validateFields() -> String?
}

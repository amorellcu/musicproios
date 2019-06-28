//
//  RegistrationController.swift
//  musicprof
//
//  Created by John Doe on 6/28/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

protocol RegistrationController: class {
    var client: Client! { get set }
}

var client: Client?

//
//  RegistrationController.swift
//  musicprof
//
//  Created by John Doe on 6/28/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

protocol RegistrationController: class {
    var user: User! { get set }
}

protocol ClientRegistrationController: RegistrationController {
    var client: Client! { get set }
}

extension ClientRegistrationController {
    var user: User! {
        get { return client }
        set { client = newValue as? Client }
    }
}

protocol ProfessorRegistrationController: RegistrationController {
    var professor: Professor! { get set }
}

extension ProfessorRegistrationController {
    var user: User! {
        get { return professor }
        set { professor = newValue as? Professor }
    }
}

//
//  LoginController.swift
//  musicprof
//
//  Created by John Doe on 7/9/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

protocol LoginController {
    
}

extension LoginController where Self: UIViewController {
    func login(withAccount user: User) {
        switch user {
        case let client as Client:
            self.performSegue(withIdentifier: "login", sender: client)
        case let professor as Professor:
            self.performSegue(withIdentifier: "loginProfessor", sender: professor)
        default:
            break
        }
    }
}

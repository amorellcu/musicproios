//
//  LoginController.swift
//  musicprof
//
//  Created by John Doe on 7/9/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import PushNotifications

protocol LoginController {
    
}

extension LoginController where Self: UIViewController {
    func login(withAccount user: User) {
        switch user {
        case let client as Client:
            self.performSegue(withIdentifier: "login", sender: client)
            try? PushNotifications.shared.setDeviceInterests(interests: ["musicprof-C\(client.id)"])
        case let professor as Professor:
            self.performSegue(withIdentifier: "loginProfessor", sender: professor)
            try? PushNotifications.shared.setDeviceInterests(interests: ["musicprof-P\(professor.id)"])
        default:
            break
        }
    }
}

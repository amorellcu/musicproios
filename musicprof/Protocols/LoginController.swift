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
            try? PushNotifications.shared.setDeviceInterests(interests: ["musicprof-C\(client.id)", "musicprof-clients"])
            if let msgCount = client.nextReservations?.countUnreadMessages() {
                UIApplication.shared.applicationIconBadgeNumber = msgCount
            }
        case let professor as Professor:
            self.performSegue(withIdentifier: "loginProfessor", sender: professor)
            try? PushNotifications.shared.setDeviceInterests(interests: ["musicprof-P\(professor.id)", "musicprof-profesors"])
            if let msgCount = professor.classes?.countUnreadMessages() {
                UIApplication.shared.applicationIconBadgeNumber = msgCount
            } else {
                self.service.getNextClasses(of: professor) { (result) in
                    switch result {
                    case .success(let classes):
                        guard let count = classes.countUnreadMessages() else { return }
                        UIApplication.shared.applicationIconBadgeNumber = count
                    default:
                        break
                    }
                }
            }
        default:
            break
        }
    }
}

extension Array where Element == Reservation {
    func countUnreadMessages() -> Int {
        var count = 0
        for reservation in self {
            count += reservation.unreadMessages ?? 0
        }
        return count
    }
}

extension Array where Element == Class {
    func countUnreadMessages() -> Int? {
        var count = 0
        for _class in self {
            guard let reservations = _class.reservations else { return nil }
            count += reservations.countUnreadMessages()
        }
        return count
    }
}

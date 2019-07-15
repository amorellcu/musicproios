//
//  ClassController.swift
//  musicprof
//
//  Created by John Doe on 7/15/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

protocol ClassController: class {
    var reservation: ClassRequest! { get set }
}

extension ClassController {
    var calendar: Calendar {
        return reservation.calendar ?? Calendar.current
    }
}

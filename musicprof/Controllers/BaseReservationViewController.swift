//
//  BaseReservationViewController.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class BaseReservationViewController: UIViewController, ReservationController, NestedController {
    open var reservation: ReservationRequest!
    weak var container: ContainerViewController?
    
    var student: Student? {
        guard let clientId = self.reservation.studentId else { return nil }
        if let type = self.reservation.studentType, type == .account {
            return self.service.currentClient
        }
        return self.service.currentClient?.subaccounts?.first(where: {$0.id == clientId})
    }
    
    var calendar: Calendar! {
        return self.reservation.calendar
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ReservationController {
            controller.reservation = self.reservation
        }
        if let controller = segue.destination as? NestedController {
            controller.container = self.container
        }
    }
}

//
//  BaseReservationViewController.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class BaseReservationViewController: BaseNestedViewController, ReservationController {
    open var reservation: ReservationRequest!    
    
    var student: Student? {
        guard let clientId = self.reservation.studentId else { return nil }
        switch self.reservation.studentType {
        case .subaccount:
            return self.service.currentClient?.subaccounts?.first(where: {$0.id == clientId})
        case .guest:
            return Guest(userId: self.service.currentClient?.id ?? 0,
                         name: self.reservation.guestName ?? "", email: self.reservation.guestEmail ?? "",
                         address: self.reservation.address, locationId: self.reservation.locationId)
        default:
            return self.service.currentClient
        }        
    }
    
    var calendar: Calendar! {
        return self.reservation.calendar
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? ReservationController {
            controller.reservation = self.reservation
        }
    }
}

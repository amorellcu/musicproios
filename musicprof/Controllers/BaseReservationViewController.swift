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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let credits = self.service.currentClient?.credits, credits == 0 {
            SCLAlertView().showWarning("Compre un paquete", subTitle: "Por favor, compre un paquete de clases antes de continuar.")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? ReservationController {
            controller.reservation = self.reservation
        }
    }
}

//
//  BaseReservationViewController.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class BaseReservationViewController: UIViewController, ReservationController {
    var reservation: ReservationRequest!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? ReservationController else {
            return
        }
        controller.reservation = self.reservation
    }
}

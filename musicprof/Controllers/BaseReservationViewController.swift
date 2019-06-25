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
    
    var client: Client? {
        guard let clientId = self.reservation.clientId else { return nil }
        return self.service.getClient(withId: clientId)
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

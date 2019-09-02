//
//  OldReservationsViewController.swift
//  musicprof
//
//  Created by John Doe on 7/17/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class OldReservationsViewController: ReservationListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadReservations(_ reservations: [Reservation]) {
        let date = Date()
        self.sections = [Section(name: nil, classes:
            reservations.lazy.compactMap({$0.classes}).filter({$0.date < date}))]
        self.tableView.reloadData()
    }
}

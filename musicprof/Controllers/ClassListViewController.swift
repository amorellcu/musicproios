//
//  ClassListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/4/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ClassListViewController: ReservationListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.timeStyle = .none
        self.dateFormatter.dateStyle = .long
        self.reservations = self.service.user?.nextReservations?.compactMap({$0.classes})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.client = self.service.user
        super.viewWillAppear(animated)
    }
    
    override func updateReservations() {
        self.service.getNextClasses(of: self.client) { [weak self] (result) in
            self?.handleResult(result) {
                self?.reservations = $0
            }
        }
    }
    
    @IBAction func onMakeReservation(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        //self.performSegue(withIdentifier: "makeReservation", sender: sender)
    }
}

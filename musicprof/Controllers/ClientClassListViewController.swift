//
//  ClassListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/4/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ClientClassListViewController: ReservationListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.timeStyle = .none
        self.dateFormatter.dateStyle = .long
        self.reservations = self.service.currentClient?.nextReservations?.compactMap({$0.classes})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func updateReservations() {
        guard let client = self.service.currentClient else { return }
        self.service.getNextClasses(of: client) { [weak self] (result) in
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

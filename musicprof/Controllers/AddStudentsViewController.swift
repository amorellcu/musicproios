//
//  AddStudentsViewController.swift
//  musicprof
//
//  Created by John Doe on 6/23/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class AddStudentsViewController: ContactInfoViewController, ReservationController {
    var reservation: ReservationRequest!
    @IBOutlet weak var continueButton: TransparentButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentClient = self.service.currentClient {
            self.client = Client(copy: currentClient)
            self.client.name = ""
            self.client.email = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func validateFields() -> String? {
        if let error = super.validateFields() {
            return error
        }
        if addressTextField?.text?.isEmpty ?? true {
            return "Por favor, introduce tu dirección."
        }
        if location == nil {
            return "No se pudo encontrar la ubicación."
        }
        return nil
    }
    
    override func updateClient() {
        super.updateClient()
        
        self.continueButton.isEnabled = self.validateFields() == nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.reservation.studentType = .guest
        self.reservation.guestName = self.client.name
        self.reservation.guestEmail = self.client.email
        self.reservation.locationId = self.client.locationId
        self.reservation.address = self.client.address
        if let controller = segue.destination as? ReservationController {
            controller.reservation = self.reservation
        }
    }
}


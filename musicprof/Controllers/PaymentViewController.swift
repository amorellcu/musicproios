//
//  PaymentViewController.swift
//  musicprof
//
//  Created by John Doe on 7/2/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    var package: Package?
    
    var paypalToken: String? {
        didSet {
            self.paypalButton.isEnabled = self.paypalToken != nil
        }
    }
    
    @IBOutlet weak var paypalButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}



//
//  ProfileUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 6/30/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ProfileUpdateViewController: CustomTabController, RegistrationController, NestedController {
    var container: ContainerViewController?
    
    var client: Client!
    
    @IBOutlet weak var updateButton: UIButton!
    
    override var sections: [UIViewController] {
        let controllers = [self.storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "InstrumentListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "ReservationListViewController")]
        for controller in controllers.lazy.compactMap({$0 as? RegistrationController}) {
            controller.client = self.client
        }
        return controllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.client = self.service.user!
    }

    override func viewWillAppear(_ animated: Bool) {        
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    @IBAction func onUpdateAccount(_ sender: Any) {
        
    }
}



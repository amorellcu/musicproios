//
//  ClientUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 7/9/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ClientUpdateViewController: ProfileUpdateViewController {
    
    private lazy var viewControllers: [UIViewController] = {
        let controllers = [self.storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "InstrumentListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "ReservationListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "PasswordUpdateViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "SubaccountListViewController")]
        for controller in controllers.lazy.compactMap({$0 as? RegistrationController}) {
            controller.user = self.user
        }
        return controllers
    }()
    
    override var sections: [UIViewController]  {
        return viewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func willShow(section controller: Section) {
        super.willShow(section: controller)
        if let controller = controller as? RegistrationController, let originalClient = self.service.currentClient {
            controller.user = Client(copy: originalClient)
        }
    }
}

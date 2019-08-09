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
        return controllers
    }()
    
    override var sections: [UIViewController]  {
        return viewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let locationId = self.service.currentClient?.locationId, locationId != 0 else {
            return SCLAlertView().showWarning("Ubicación desconocida", subTitle: "Por favor, introduzca su dirección antes de continuar.", closeButtonTitle: "Aceptar").setDismissBlock {
                self.menu?.gotoAccount()
                self.menu?.lockCurrentSection()
            }
        }
    }
    
    override func willShow(section controller: Section) {
        if let controller = controller as? RegistrationController, let originalClient = self.service.currentClient {
            controller.user = Client(copy: originalClient)
        }
        super.willShow(section: controller)
    }
}

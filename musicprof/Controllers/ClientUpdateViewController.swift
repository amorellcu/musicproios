//
//  ClientUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 7/9/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ClientUpdateViewController: ProfileUpdateViewController, ClientRegistrationController {

    var client: Client! {
        get { return self.user as? Client }
        set { self.user = newValue }
    }
    var originalClient: Client?
    
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

        self.client = self.service.currentClient!
        self.originalClient = self.originalClient ?? Client(copy: self.client)
        self.updateControllers()
    }
    
    override func updateAccount() {
        guard self.client != self.originalClient else {
            return
        }
        self.showSpinner(onView: self.view)
        self.service.updateProfile(self.client) { [weak self] (result) in
            self?.removeSpinner()
            self?.handleResult(result) {
                self?.client = $0
                self?.originalClient = Client(copy: $0)
                self?.updateControllers()
                SCLAlertView().showSuccess("Cuenta Actualizada", subTitle: "La configuración de su cuenta se actualizó correctamente.")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let controller = segue.destination as? InstrumentsRegistrationViewController else { return }
        switch segue.identifier {
        case "addSubaccount":
            controller.client = self.client
        case "editSubaccount":
            controller.client = self.client
            controller.subaccount = sender as? Subaccount
        default:
            break
        }
    }
    
    @IBAction func unwindToProfile(_ segue: UIStoryboardSegue) {
        self.client = self.service.currentClient!
        self.updateControllers()
    }
}

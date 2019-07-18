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
    var originalClient: Client? {
        return self.service.currentClient
    }
    
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

        if let client = self.originalClient {
            self.client = Client(copy: client)
        }
        self.updateControllers()
    }
    
    override func updateAccount() {
        guard self.client != self.originalClient else {
            return
        }
        let alert = self.showSpinner(withMessage: "Actualizando datos...")
        self.service.updateProfile(self.client) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                self?.client = Client(copy: $0)
                self?.updateControllers()
                self?.container?.refresh()
                SCLAlertView().showSuccess("Cuenta Actualizada", subTitle: "La configuración de su cuenta se actualizó correctamente.", closeButtonTitle: "Aceptar")
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
        self.client.subaccounts = self.service.currentClient?.subaccounts
        self.updateControllers()
    }
}

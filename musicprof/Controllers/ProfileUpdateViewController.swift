//
//  ProfileUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 6/30/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import FacebookCore
import SCLAlertView

class ProfileUpdateViewController: CustomTabController, RegistrationController, NestedController {
    var container: ContainerViewController?
    
    var client: Client!
    var originalClient: Client?
    
    @IBOutlet weak var updateButton: UIButton!
    
    private lazy var viewControllers: [UIViewController] = {
        let controllers = [self.storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "InstrumentListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "ReservationListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "PasswordUpdateViewController")]
        for controller in controllers.lazy.compactMap({$0 as? RegistrationController}) {
            controller.client = self.client
        }
        return controllers
    }()
    
    override var sections: [UIViewController]  {
        return viewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.client = self.service.user!
        self.originalClient = self.originalClient ?? Client(copy: self.client)
        self.updateControllers()
    }

    override func viewWillAppear(_ animated: Bool) {        
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    private func updateControllers() {
        for controller in self.viewControllers.lazy.compactMap({$0 as? RegistrationController}) {
            controller.client = self.client
        }
    }
    
    @IBAction func onUpdateAccount(_ sender: Any) {
        if let passwordController = self.viewControllers.compactMap({$0 as? PasswordUpdateViewController}).first {
            self.changePassword(with: passwordController) {
                self.updateAccount()
            }
        } else {
            self.updateAccount()
        }
        
    }
    
    func updateAccount() {
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
            }
        }
    }
    
    func changePassword(with controller: PasswordUpdateViewController, continueWith handler: @escaping () -> Void) {
        guard controller.isViewLoaded else {
            return handler()
        }
        let password = controller.passwordTextField.text ?? ""
        let passwordConfirmation = controller.passwordConfirmationTextField.text ?? ""
        if password.isEmpty && passwordConfirmation.isEmpty {
            return handler()
        }
        if password != passwordConfirmation {
            self.notify(message: "Las contraseñas no coinciden", title: "Error")
        }
        controller.passwordTextField.text = nil
        controller.passwordConfirmationTextField.text = nil
        self.showSpinner(onView: self.view)
        self.service.changePassword(to: password) { [weak self] (result) in
            self?.removeSpinner()
            self?.handleResult(result, onSuccess: handler)
        }
    }
}



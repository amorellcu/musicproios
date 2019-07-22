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

class ProfileUpdateViewController: CustomTabController {
    open var user: User!
    
    @IBOutlet weak var updateButton: UIButton?    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func willShow(section controller: Section) {
        super.willShow(section: controller)
        if let controller = controller as? RegistrationController {
            controller.user = self.user
        }
        if let controller = controller as? NestedController {
            controller.container = self.container
        }
        if let controller = controller as? BaseNestedViewController {
            controller.preferredDisplayMode = .picture
        }
        if let controller = controller as? ProfileSection {
            controller.updater = self
            controller.refresh()
        }
    }
    
    @IBAction open func onUpdateAccount(_ sender: Any) {
        if let passwordController = self.sections.compactMap({$0 as? PasswordUpdateViewController}).first {
            self.changePassword(with: passwordController) {
                self.updateAccount()
            }
        } else {
            self.updateAccount()
        }
        
    }
    
    open func updateAccount() {
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
        let alert = self.showSpinner(withMessage: "Cambiando contraseña...")
        self.service.changePassword(to: password) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                    showCloseButton: false
                ))
                alert.addButton("Aceptar", action: handler)
                alert.showSuccess("Contraseña Actualizada", subTitle: "La contraseña se actualizó correctamente.")
            }
        }
    }
}



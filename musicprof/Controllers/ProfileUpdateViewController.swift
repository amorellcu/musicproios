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
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    var client: Client!
    var originalClient: Client?
    
    @IBOutlet weak var updateButton: UIButton!
    
    private lazy var viewControllers: [UIViewController] = {
        let controllers = [self.storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "InstrumentListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "ReservationListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "PasswordUpdateViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "SubaccountListViewController")]
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
        
        if let avatarImageView = self.container?.avatarImageView {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileUpdateViewController.onChangeAvatar))
            avatarImageView.addGestureRecognizer(gestureRecognizer)
            self.tapGestureRecognizer = gestureRecognizer
            self.tapGestureRecognizer?.isEnabled = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tapGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tapGestureRecognizer?.isEnabled = false
    }
    
    private func updateControllers() {
        for controller in self.viewControllers {
            if let controller = controller as? RegistrationController {
                controller.client = self.client
            }
            if let controller = controller as? ProfileSection {
                controller.updater = self
                controller.refresh()
            }
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
                SCLAlertView().showSuccess("Cuenta Actualizada", subTitle: "La configuración de su cuenta se actualizó correctamente.")
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
            self?.handleResult(result) {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                    showCloseButton: false
                ))
                alert.addButton("Aceptar", action: handler)
                alert.showSuccess("Contraseña Actualizada", subTitle: "La contraseña se actualizó correctamente.")
            }
        }
    }
    
    @objc func onChangeAvatar() {
        ImageImporter(viewController: self).getPicture(for: self.client) { [weak self] in
            guard let url = self?.client?.avatarUrl, url.isFileURL else { return }
            self?.container?.avatarImageView.image = UIImage(contentsOfFile: url.path)?.af_imageRoundedIntoCircle()
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
            controller.editClient = sender as? Client
        default:
            break
        }
    }
    
    @IBAction func unwindToProfile(_ segue: UIStoryboardSegue) {
        self.client = self.service.user!
        self.updateControllers()
    }
}



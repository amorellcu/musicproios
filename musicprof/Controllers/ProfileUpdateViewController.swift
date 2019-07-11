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

class ProfileUpdateViewController: CustomTabController, NestedController {
    weak var container: ContainerViewController?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var imageImporter: ImageImporter!
    
    open var user: User!
    
    @IBOutlet weak var updateButton: UIButton!
    
    override func loadView() {
        imageImporter = ImageImporter(viewController: self)
        
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func updateControllers() {
        for controller in self.sections {
            if let controller = controller as? RegistrationController {
                controller.user = self.user
            }
            if let controller = controller as? ProfileSection {
                controller.updater = self
                controller.refresh()
            }
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
        imageImporter.getPicture(for: self.user) { [weak self] in
            guard let url = self?.user?.avatarUrl, url.isFileURL else { return }
            self?.container?.avatarImageView.image = UIImage(contentsOfFile: url.path)?.af_imageRoundedIntoCircle()
        }
    }
}



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
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onChangeAvatar))
            avatarImageView.addGestureRecognizer(gestureRecognizer)
            self.tapGestureRecognizer = gestureRecognizer
            self.tapGestureRecognizer?.isEnabled = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.preferredDisplayMode = .picture
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tapGestureRecognizer?.isEnabled = true
        
        let image = UIImage(named: "change-avatar")
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onChangeAvatar))
        self.container?.avatarToolbar.setItems([buttonItem], animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tapGestureRecognizer?.isEnabled = false
        self.container?.avatarToolbar.setItems([], animated: animated)
    }
    
    func updateControllers() {
        for controller in self.sections {
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
    
    @objc func onChangeAvatar() {
        imageImporter.getPicture(for: self.user) { [weak self] in
            guard let url = self?.user?.avatarUrl, url.isFileURL else { return }
            self?.container?.avatarImageView.image = UIImage(contentsOfFile: url.path)?.af_imageRoundedIntoCircle()
        }
    }
}



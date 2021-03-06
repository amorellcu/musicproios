//
//  ContactInfoUpdateViewController.swift
//  musicprof
//
//  Created by Jon Doe on 7/22/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage
import SCLAlertView

class ContactInfoUpdateViewController: ContactInfoViewController {
    
    var imageImporter: ImageImporter!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func loadView() {
        imageImporter = ImageImporter(viewController: self)
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let avatarImageView = self.container?.avatarImageView {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onChangeAvatar))
            avatarImageView.addGestureRecognizer(gestureRecognizer)
            self.tapGestureRecognizer = gestureRecognizer
            self.tapGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tapGestureRecognizer?.isEnabled = true
        
        let image = UIImage(named: "change-avatar")
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onChangeAvatar))
        self.container?.avatarToolbar.setItems([buttonItem], animated: animated)
        self.container?.setAvatar(self.user.avatarUrl)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tapGestureRecognizer?.isEnabled = false
        self.container?.avatarToolbar.setItems([], animated: animated)
        self.container?.refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func validateFields() -> String? {
        switch self.user {
        case let client as Client where client == self.service.currentClient:
            return "No hay cambios que guardar"
        case let professor as Professor where professor == self.service.currentProfessor:
            return "No hay cambios que guardar"
        default:
            break
        }
        return super.validateFields()
    }
    
    @IBAction func onSaveChanges(_ sender: Any) {
        self.updateClient()
        
        if let error = self.validateFields() {
            return self.notify(message: error, title: "Información inválida")
        }
        
        let alert = self.showSpinner(withMessage: "Actualizando cambios...")
        self.service.updateUser(self.user) { (result) in
            alert.hideView()
            self.handleResult(result) {
                self.user = $0
                if let client = $0 as? Client, client.locationId != nil && client.locationId != 0 {
                    self.menu?.unlockAllSections()
                }
                SCLAlertView()
                    .showSuccess("Cuenta Actualizada",
                    subTitle: "La configuración de su cuenta se actualizó correctamente.",
                    closeButtonTitle: "Aceptar")
                    .setDismissBlock { [weak self] in
                        self?.goBack()
                }
            }
        }
    }
        
    @objc func onChangeAvatar() {
        imageImporter.getPicture(for: self.user) { [weak self] in
            guard let url = self?.user?.avatarUrl, url.isFileURL else { return }
            //self?.container?.avatarImageView.image = UIImage(contentsOfFile: url.path)?.af_imageRoundedIntoCircle()
        }
    }
}

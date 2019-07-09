//
//  ProfessorUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 7/9/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ProfessorUpdateViewController: ProfileUpdateViewController {
    
    var professor: Professor! {
        get { return self.user as? Professor }
        set { self.user = newValue }
    }
    var originalProfessor: Professor?
    
    private lazy var viewControllers: [UIViewController] = {
        let controllers = [self.storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "PasswordUpdateViewController")]
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
        
        self.professor = self.service.currentProfessor!
        self.originalProfessor = self.originalProfessor ?? Professor(copy: self.professor)
        self.updateControllers()
    }
    
    override func onUpdateAccount(_ sender: Any) {
        guard self.professor != self.originalProfessor else {
            if let controller = self.sections.compactMap({$0 as? PasswordUpdateViewController}).first {
                return super.changePassword(with: controller) { }
            } else {
                return
            }
        }
        
        var newPassword: String? = nil
        if let controller = self.sections.compactMap({$0 as? PasswordUpdateViewController}).first {
            let password = controller.passwordTextField.text ?? ""
            let passwordConfirmation = controller.passwordConfirmationTextField.text ?? ""
            if !password.isEmpty && !passwordConfirmation.isEmpty && password == passwordConfirmation {
                newPassword = password
            }
        }
        
        self.showSpinner(onView: self.view)
        self.service.updateProfile(self.professor, password: newPassword) { [weak self] (result) in
            self?.removeSpinner()
            self?.handleResult(result) {
                self?.professor = $0
                self?.originalProfessor = Professor(copy: $0)
                self?.updateControllers()
                SCLAlertView().showSuccess("Cuenta Actualizada", subTitle: "La configuración de su cuenta se actualizó correctamente.")
            }
        }
    }
}

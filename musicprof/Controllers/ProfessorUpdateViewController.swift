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
    var originalProfessor: Professor? {
        return self.service.currentProfessor
    }
    
    private lazy var viewControllers: [UIViewController] = {
        let controllers = [self.storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "InstrumentListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "LocationListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "PersonalReviewViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "AcademicTrainingViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "WorkExperienceViewController"),
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
        
        if let professor = self.originalProfessor {
            self.professor = Professor(copy: professor)
        }
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
        if let controller = self.sections.compactMap({$0 as? PasswordUpdateViewController}).first, controller.isViewLoaded {
            let password = controller.passwordTextField.text ?? ""
            let passwordConfirmation = controller.passwordConfirmationTextField.text ?? ""
            if !password.isEmpty && !passwordConfirmation.isEmpty && password == passwordConfirmation {
                newPassword = password
            }
        }
        
        let alert = self.showSpinner(withMessage: "Actualizando datos...")
        self.service.updateProfile(self.professor, password: newPassword) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                self?.professor = Professor(copy: $0)
                self?.container?.refresh()
                SCLAlertView().showSuccess("Cuenta Actualizada", subTitle: "La configuración de su cuenta se actualizó correctamente.", closeButtonTitle: "Aceptar")
            }
        }
    }
}

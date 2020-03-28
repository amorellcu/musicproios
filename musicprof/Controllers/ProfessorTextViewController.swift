//
//  ProfessorTextViewController.swift
//  musicprof
//
//  Created by John Doe on 7/9/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ProfessorTextViewController: BaseNestedViewController, ProfessorRegistrationController, ProfileSection {
    weak var updater: ProfileUpdateViewController?
    var professor: Professor! 
    
    open var text: String?
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self.view, action: #selector(UIView.endEditing(_:)))
        toolbar.items = [flexSpace, doneButton]
        toolbar.sizeToFit()
        
        self.textView.inputAccessoryView = toolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refresh()
    }
    
    func refresh() {
        guard self.isViewLoaded else { return }
        self.textView.text = text
    }
    
    func updateProfessor() {
        self.text = self.textView.text
    }
    
    @IBAction func onSaveChanges(_ sender: Any) {
        self.textView.resignFirstResponder()
        self.updateProfessor()
        
        guard self.professor != self.service.currentProfessor else {
            return notify(message: "No hay cambios que guardar.", title: "Error")
        }
        
        let alert = self.showSpinner(withMessage: "Actualizando cambios...")
        let user = self.user!
        self.service.updateUser(user) { (result) in
            alert.hideView()
            self.handleResult(result) {
                self.user = $0
                let alert = SCLAlertView()
                alert.showSuccess(
                    "Cuenta Actualizada",
                    subTitle: "La configuración de su cuenta se actualizó correctamente.",
                    closeButtonTitle: "Aceptar")
            }
        }
    }
}

extension ProfessorTextViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.updateProfessor()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.updateProfessor()
    }
}

class PersonalReviewViewController: ProfessorTextViewController {
    override var text: String? {
        get { return professor.personalReview }
        set { professor.personalReview = newValue }
    }
}

class AcademicTrainingViewController: ProfessorTextViewController {
    override var text: String? {
        get { return professor.academicTraining }
        set { professor.academicTraining = newValue }
    }
}

class WorkExperienceViewController: ProfessorTextViewController {
    override var text: String? {
        get { return professor.workExperience }
        set { professor.workExperience = newValue }
    }
}

//
//  ProfessorTextViewController.swift
//  musicprof
//
//  Created by John Doe on 7/9/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

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
}

extension ProfessorTextViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.updateProfessor()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.updateProfessor()
        return true
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

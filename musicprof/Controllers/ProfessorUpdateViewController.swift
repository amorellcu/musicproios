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
    
    private lazy var viewControllers: [UIViewController] = {
        let controllers = [self.storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "InstrumentListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "LocationListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "PersonalReviewViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "AcademicTrainingViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "WorkExperienceViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "PasswordUpdateViewController")]
        return controllers
    }()
    
    override var sections: [UIViewController]  {
        return viewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func willShow(section controller: Section) {
        if let controller = controller as? RegistrationController, let originalUser = self.service.currentProfessor {
            controller.user = Professor(copy: originalUser)
        }
        super.willShow(section: controller)
    }
}

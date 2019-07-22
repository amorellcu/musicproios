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
    @IBOutlet weak var updateButton: UIButton?    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func willShow(section controller: Section) {
        if let controller = controller as? NestedController {
            controller.container = self.container
        }
        if let controller = controller as? BaseNestedViewController {
            //controller.preferredDisplayMode = .picture
        }
        if let controller = controller as? ProfileSection {
            controller.updater = self
            controller.refresh()
        }
        super.willShow(section: controller)
    }
}



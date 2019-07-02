//
//  ProfileUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 6/30/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import FacebookCore

class ProfileUpdateViewController: CustomTabController, RegistrationController, NestedController {
    var container: ContainerViewController?
    
    var client: Client!
    
    @IBOutlet weak var updateButton: UIButton!
    
    private lazy var viewControllers: [UIViewController] = {
        let controllers = [self.storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "InstrumentListViewController"),
                           self.storyboard!.instantiateViewController(withIdentifier: "ReservationListViewController")]
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
    }

    override func viewWillAppear(_ animated: Bool) {        
        self.container?.setDisplayMode(.full, animated: animated)
        self.client = self.service.user!
        self.updateControllers()
    }
    
    private func updateControllers() {
        for controller in self.viewControllers.lazy.compactMap({$0 as? RegistrationController}) {
            controller.client = self.client
        }
    }
    
    @IBAction func onUpdateAccount(_ sender: Any) {
        self.showSpinner(onView: self.view)
        self.service.updateProfile(self.client) { [weak self] (result) in
            self?.removeSpinner()
            self?.handleResult(result) {
                self?.client = $0
                self?.updateControllers()
            }
        }
    }
}



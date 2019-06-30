//
//  CustomTabController.swift
//  musicprof
//
//  Created by John Doe on 6/30/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

@IBDesignable class CustomTabController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func navigate(to section: String) {
        self.performSegue(withIdentifier: section, sender: self)
    }
}

//
//  BaseNestedViewController.swift
//  musicprof
//
//  Created by John Doe on 7/13/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class BaseNestedViewController: UIViewController, NestedController {
    weak var container: ContainerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateBackButton()
    }
    
    func updateBackButton() {
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            let image = UIImage(named: "left")
            self.container?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goBack))
        } else {
            self.container?.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? NestedController {
            controller.container = self.container
        }
    }
}

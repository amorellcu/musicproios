//
//  RegisterStepOneViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 29/01/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import AlamofireImage

class ContactInfoRegistrationViewController: ContactInfoViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func loadView() {
        self.client = Client()
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if FBSDKAccessToken.current() == nil {
            self.updateFields()
        } else {
            self.client.loadFromFB { [weak self] (error) in
                if (error == nil) {
                    self?.updateFields()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func updateFields() {
        let placeholderAvatar = UIImage(named:"userdefault")
        if let avatarUrl = self.client.avatarUrl {
            let filter = ScaledToSizeCircleFilter(size: self.avatarImageView.frame.size)
            self.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: UIImage(named:"userdefault"), filter: filter)
        } else {
            self.avatarImageView.image = placeholderAvatar?.af_imageAspectScaled(toFit: self.avatarImageView.frame.size).af_imageRoundedIntoCircle()
        }
        super.updateFields()
    }
    
    @IBAction func onRegisterSubaccounts(_ sender: Any) {
        self.showSpinner(onView: self.view)
        self.service.registerClient(self.client) { (result) in
            self.removeSpinner()
            self.handleResult(result) {
                self.client = $0
                self.performSegue(withIdentifier: "registerStudents", sender: sender)
            }
        }
    }
}

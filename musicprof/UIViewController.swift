//
//  UIViewController.swift
//  musicprof
//
//  Created by John Doe on 5/26/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

extension UIViewController {
    var api: ApiStudent {
        return ApiStudent.sharedInstance
    }
    
    func onLogoutAction(activityIndicator ai: UIActivityIndicatorView, closeIcon icon: UIImageView) {
        ai.startAnimating()
        icon.isHidden = true
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        self.api.setHeaders(aheader: headers)
        self.api.logout(){ json, err in
            ai.stopAnimating()
            icon.isHidden = false
            
            if(err != nil) {
                self.performSegue(withIdentifier: "unwindToLogin", sender: self)
            } else {
                
            }
        }
    }
}

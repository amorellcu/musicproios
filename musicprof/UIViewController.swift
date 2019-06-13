//
//  UIViewController.swift
//  musicprof
//
//  Created by John Doe on 5/26/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

var vSpinner : UIView?

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
    
    //Spinner dialog
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

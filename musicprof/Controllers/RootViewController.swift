//
//  RootViewController.swift
//  musicprof
//
//  Created by John Doe on 5/25/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import SCLAlertView

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        
        ////////////////////////////
        
        if self.service.isSignedIn {
            self.performSegue(withIdentifier: "goToCalendar", sender: self)
        }
        else if let accessToken = AccessToken.current{
            print(">>> token found: "+accessToken.authenticationToken)
            self.service.signIn(withFacebookToken: accessToken.authenticationToken) { [weak self] (result) in
                self?.handleResult(result, onError: { (_) in
                    self?.performSegue(withIdentifier: "RequireLogin", sender: self)
                }, onSuccess: { (_) in
                    // TODO: check for registration
                    /*
                     if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepOne") as? RegisterStepOneViewController {
                     if let navigator = self.navigationController {
                     navigator.pushViewController(viewController, animated: true)
                     }
                     }
                     */
                    self?.performSegue(withIdentifier: "goToCalendar", sender: self)
                })
            }
        } else {
            self.performSegue(withIdentifier: "RequireLogin", sender: self)
        }
        
        ////////////////////
        
        //        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //        let vc: UIViewController
        //        if AccessToken.current != nil {
        //            vc = mainStoryboard.instantiateViewController(withIdentifier: "UserCalendar") as! CalendarViewController
        //        } else {
        //            vc = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! ViewController
        //        }
        //        let navCtrl = UINavigationController(rootViewController: vc)
        //        self.window = UIWindow(frame: UIScreen.main.bounds)
        //        self.window!.rootViewController = navCtrl
        //        self.window!.makeKeyAndVisible()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

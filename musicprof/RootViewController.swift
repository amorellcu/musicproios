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
        if let accessToken = FBSDKAccessToken.current(){
            print(">>> token found: "+accessToken.tokenString)
            let parameters = [
                "token": accessToken.tokenString!
            ]
            self.api.setParams(aparams: parameters)
            self.api.loginFacebookToken() { json, error  in
                if(error != nil){
                    print(">>>error != nil")
                    let alertView = SCLAlertView()
                    alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor")
                    self.performSegue(withIdentifier: "RequireLogin", sender: self)
                }
                else{
                    print(">>>error == nil")
                    let JSON = json! as NSDictionary
                    if(String(describing: JSON["result"]!) == "Error"){
                        print(">>> json result == Error")
                        let alertView = SCLAlertView()
                        alertView.showError("Error Autenticación", subTitle: String(describing: JSON["message"]!)) // Error
                    } else if(String(describing: JSON["result"]!) == "OK"){
                        print(">>> JSON[result] == OK")
                        if(String(describing: JSON["code"]!) == "202"){
                            print(">>>valid user, requires registration")
                            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepOne") as? RegisterStepOneViewController {
                                if let navigator = self.navigationController {
                                    navigator.pushViewController(viewController, animated: true)
                                }
                            }
                        }
                        else {
                            print(">>>login successfull")
                            self.api.user = JSON
                            print(">>> set this to api user:" + String(describing: self.api.user))
                            let userdata = self.api.getUserData(JSON: JSON)
                            self.api.urlphoto = userdata["urlphoto"]!
                            self.api.nameclient = userdata["name"]!
                            self.performSegue(withIdentifier: "goToCalendar", sender: self)
                        }
                    }
                }
            }
        }
        else {
            print(">>> token not found")
            performSegue(withIdentifier: "RequireLogin", sender: self)
                //nav.performSegue(withIdentifier: "RequireLogin", sender: self)
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

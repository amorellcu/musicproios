//
//  ViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 29/01/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView
import Alamofire

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit


class ViewController: UIViewController,UITextFieldDelegate {

    var dict : [String : AnyObject]!
//    var nameclient = ""
//    var urlphoto = ""
    //var user:NSDictionary = [:]
    
    @IBOutlet weak var customFBLoginButton: UIButton!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    
    let configuration = Configuration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        //if the user is already logged in
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterStepOneViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
//        if let accessToken = FBSDKAccessToken.current(){
//            let parameters = [
//                "token": accessToken.tokenString!
//            ]
//            apimusicprof.setParams(aparams: parameters)
//            apimusicprof.loginFacebookToken() { json, error  in
//                if(error != nil){
//                    let alertView = SCLAlertView()
//                    alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor")
//                }
//                else{
//                    let JSON = json! as NSDictionary
//                    if(String(describing: JSON["result"]!) == "Error"){
//                        let alertView = SCLAlertView()
//                        alertView.showError("Error Autenticación", subTitle: String(describing: JSON["message"]!)) // Error
//                    } else if(String(describing: JSON["result"]!) == "OK"){
//                        if(String(describing: JSON["code"]!) == "202"){
//                            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepOne") as? RegisterStepOneViewController {
//                                if let navigator = self.navigationController {
//                                    navigator.pushViewController(viewController, animated: true)
//                                }
//                            }
//                        }
//                        else {
//                            self.user = JSON
//                            let userdata = self.getUserData(JSON: JSON)
//                            self.urlphoto = userdata["urlphoto"]!
//                            self.nameclient = userdata["name"]!
//                            self.performSegue(withIdentifier: "calendar", sender: self)
//                        }
//                        
//                    }
//                }
//                
//            }
//        }
        emailText.delegate = self
        passText.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: self.emailText.frame.height))
        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: self.passText.frame.height))
        self.emailText.leftView = paddingView
        self.emailText.leftViewMode = UITextFieldViewMode.always
        self.passText.leftView = paddingView1
        self.passText.leftViewMode = UITextFieldViewMode.always
        self.passText.isSecureTextEntry = true
        customFBLoginButton.addTarget(self, action: #selector(loginButtonClicked), for: UIControlEvents.touchUpInside)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailText.text = ""
        passText.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailText.resignFirstResponder()
        passText.resignFirstResponder()
        return true
    }
    
//    func getUserData(JSON: NSDictionary)->[String:String]{
//        var userdata = [String:String]()
//        if(String(describing: JSON["result"]!) == "Error"){
//            let alertView = SCLAlertView()
//            alertView.showError("Error Autenticación", subTitle: String(describing: JSON["message"]!)) // Error
//        } else if(String(describing: JSON["result"]!) == "OK"){
//            let data = JSON["data"] as? [String: Any]
//            let cliente = data!["client"] as? [String: Any]
//            let subaccounts = cliente!["subaccounts"] as! NSArray
//            let user = cliente!["user"] as? [String: Any]
//            userdata["urlphoto"] = user!["photo"] as? String
//            if(subaccounts.count > 0){
//                let subcuenta = subaccounts[0] as? [String: Any]
//                userdata["name"] = subcuenta!["name"] as? String
//
//            }
//            else {
//                let user = cliente!["user"] as! [String: Any]
//                userdata["name"] = user["name"] as? String
//            }
//        }
//        return userdata
//
//    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollview.contentInset = UIEdgeInsets.zero
        } else {
            scrollview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    // Once the button is clicked, show the login dialog
    //when login button clicked
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.loginBehavior = LoginBehavior.web
        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                if let accessToken = FBSDKAccessToken.current(){
                    let parameters = [
                        "token": accessToken.tokenString!
                    ]
                    self.api.setParams(aparams: parameters)
                    self.api.loginFacebookToken() { json, error  in
                        if(error != nil){
                            let alertView = SCLAlertView()
                            alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor")
                        }
                        else{
                            let JSON = json! as NSDictionary
                            if(String(describing: JSON["result"]!) == "Error"){
                                let alertView = SCLAlertView()
                                alertView.showError("Error Autenticación", subTitle: String(describing: JSON["message"]!)) // Error
                            } else if(String(describing: JSON["result"]!) == "OK"){
                                if(String(describing: JSON["code"]!) == "202"){
                                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepOne") as? RegisterStepOneViewController {
                                        if let navigator = self.navigationController {
                                            navigator.pushViewController(viewController, animated: true)
                                        }
                                    }
                                }
                                else {
                                    self.api.user = JSON
                                    let userdata = self.api.getUserData(JSON: JSON)
                                    self.api.urlphoto = userdata["urlphoto"]!
                                    self.api.nameclient = userdata["name"]!
//                                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepOne") as? RegisterStepOneViewController {
//                                        if let navigator = self.navigationController {
//                                            navigator.pushViewController(viewController, animated: true)
//                                        }
//                                    }
                                    self.performSegue(withIdentifier: "calendar", sender: self)
                                }
                                
                            }
                        }
                        
                    }
                    
                }
            }
        }
    }
    


    @IBAction func loginUser(_ sender: Any) {
        if self.emailText.text == "" || self.passText.text == ""{
            let alertView = SCLAlertView()
            alertView.showError("Error Validación", subTitle: "Asegurese que el usuario o la clave no esten vacios") // Error
        }
        else{
            
            let headers = ["Content-Type": "application/x-www-form-urlencoded"]
            let parameters = [
                "email": self.emailText.text!,//"testing113540900@gmail.com",//
                "password": self.passText.text!//"123456"//
            ]
            self.api.setHeaders(aheader: headers)
            self.api.setParams(aparams: parameters)
            
            self.api.login() { json, error  in
                if(error != nil){
                    let alertView = SCLAlertView()
                    alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor") // Error
                }
                else{
                    print("error == nil")
                    let JSON = json! as NSDictionary
                    let userdata = self.api.getUserData(JSON: JSON)
                    self.api.urlphoto = userdata["urlphoto"]
                    self.api.nameclient = userdata["name"]!
                    self.api.user = JSON
                    //self.user = JSON
                    self.performSegue(withIdentifier: "calendar", sender: self)
                }

             }
         }
    }
    
    @IBAction func buttonRegister(_ sender: Any) {
        self.performSegue(withIdentifier: "RegisterStepOneSegue", sender: self)
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
        
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier == "calendar"){
//            let Calendar = segue.destination as? CalendarViewController
//            Calendar?.Perfilname = self.api.nameclient
//            Calendar?.user = self.user
//
//        }
//    }
    
}


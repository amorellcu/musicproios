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
    
    @IBOutlet weak var customFBLoginButton: UIButton!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //if the user is already logged in
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterStepOneViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if let accessToken = FBSDKAccessToken.current(){
            //Registro
            /*if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepOne") as? RegisterStepOneViewController {
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }*/
            //Calendario
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserCalendar") as? CalendarViewController {
                 if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                 }
             }

        }
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
        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                if let accessToken = FBSDKAccessToken.current(){
                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepOne") as? RegisterStepOneViewController {
                        if let navigator = self.navigationController {
                            navigator.pushViewController(viewController, animated: true)
                        }
                    }
                    
                }
            }
        }
    }
    
    
    //function is fetching the user data
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                }
            })
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
                "email": self.emailText.text,
                "password": self.passText.text
            ]
            //let urllogin = NSURL(string: "http://127.0.0.1:8000/api/loginClient")!
            request("http://127.0.0.1:8000/api/loginClient", method: .post, parameters: parameters, headers: headers).responseJSON { response in
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    let alertView = SCLAlertView()
                    alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor") // Error

                    
                }
            }
        }
    }
    
}


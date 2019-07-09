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

import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit


class LoginViewController: UIViewController, LoginController {

    @IBOutlet weak var customFBLoginButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    
    let configuration = Configuration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //if the user is already logged in
        self.emailText.text = UserDefaults.standard.string(forKey: "user")
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        emailText.delegate = self
        passText.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: self.emailText.frame.height))
        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: self.passText.frame.height))
        self.emailText.leftView = paddingView
        self.emailText.leftViewMode = UITextFieldViewMode.always
        self.passText.leftView = paddingView1
        self.passText.leftViewMode = UITextFieldViewMode.always
        self.passText.isSecureTextEntry = true
        
        if let accessToken = AccessToken.current{
            print(">>> token found: "+accessToken.authenticationToken)
            self.login(withFBToken: accessToken)
        } else if self.service.isSignedIn {
            self.showSpinner(onView: self.view)
            self.service.getUserInfo {[weak self](result) in
                self?.removeSpinner()
                self?.handleResult(result, onSuccess: {
                    self?.login(withAccount: $0)
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        passText.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
    
    private func login(withFBToken accessToken: AccessToken) {
        self.showSpinner(onView: self.view)
        self.service.signIn(withFacebookToken: accessToken.authenticationToken, handler: { (result) in
            self.removeSpinner()
            self.handleResult(result, onError: { error in
                if let appError = error as? AppError, appError == AppError.registrationRequired {
                    self.performSegue(withIdentifier: "RegisterStepOneSegue", sender: self)
                }
            }, onSuccess: {
                self.login(withAccount: $0)
            })
        })
    }
    
    @IBAction func onLoginWithFB(_ sender: Any) {
        if let accessToken = AccessToken.current{
            return self.login(withFBToken: accessToken)
        }
        let loginManager = LoginManager()
        loginManager.loginBehavior = LoginBehavior.web
        loginManager.logIn(readPermissions: [ .publicProfile, .email ], viewController: self) { [weak self] loginResult in
            DispatchQueue.main.async {
                switch loginResult {
                case .failed(let error):
                    print(error)
                    self?.notify(error: error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    self?.login(withFBToken: accessToken)
                }
            }
        }
    }

    @IBAction func onLoginWithEmail(_ sender: Any) {
        guard let email = self.emailText.text,  //"testing113540900@gmail.com"
            let pass = self.passText.text,      //"123456"
            !email.isEmpty && !pass.isEmpty else {
                SCLAlertView().showError("Error Validación", subTitle: "Asegurese que el usuario o la clave no esten vacios") // Error
                return
        }
        self.showSpinner(onView: self.view)
        self.service.signIn(withEmail: email, password: pass) { [weak self] (result) in
            self?.removeSpinner()
            self?.handleResult(result) {
                UserDefaults.standard.set(email, forKey: "user")
                self?.performSegue(withIdentifier: "login", sender: sender)
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        self.performSegue(withIdentifier: "RegisterStepOneSegue", sender: self)
    }
    
    @IBAction func onResetPassword(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        let textField = alertView.addTextField()
        textField.text = self.emailText.text
        textField.placeholder = "Correo electrónico"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        alertView.addButton("Cambiar") {
            self.performSegue(withIdentifier: "resetPassword", sender: textField)
        }
        alertView.showEdit("Cambiar Contraseña", subTitle: "Introduzca su correo electrónico para enviarle el código de seguridad.")
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
        self.service.signOut()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PasswordResetViewController, let textField = sender as? UITextField {
            controller.email = textField.text
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField === self.passText {
            self.onLoginWithEmail(textField)
        }
        return true
    }
}

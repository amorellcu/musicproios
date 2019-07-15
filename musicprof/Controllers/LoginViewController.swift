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
import M13Checkbox

import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit


class LoginViewController: UIViewController, LoginController {

    @IBOutlet weak var customFBLoginButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var rememberCheckBox: M13Checkbox!
    
    let configuration = Configuration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //if the user is already logged in
        self.rememberCheckBox.boxType = .square
        self.rememberCheckBox.markType = .checkmark
        if let userName = UserDefaults.standard.string(forKey: "user"), !userName.isEmpty {
            self.rememberCheckBox.setCheckState(.checked, animated: true)
            self.emailText.text = userName
        }
        
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
        
        if let accessToken = AccessToken.current {
            print(">>> token found: "+accessToken.authenticationToken)
            self.login(withFBToken: accessToken)
        } else if self.service.isSignedIn {
            let alert = self.showSpinner(withMessage: "Comprobando credenciales...")
            self.service.getUserInfo {[weak self](result) in
                alert.hideView()
                switch result {
                case .success(let user):
                    self?.login(withAccount: user)
                default:
                    break
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        passText.text = ""
        if self.rememberCheckBox.checkState == .checked, let email = self.emailText.text, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: "user")
        } else {
            UserDefaults.standard.removeObject(forKey: "user")
        }
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
        let alert = self.showSpinner(withMessage: "Comprobando credenciales...")
        self.service.signIn(withFacebookToken: accessToken.authenticationToken, handler: { (result) in
            alert.hideView()
            switch result {
            case .success(let data):
                self.login(withAccount: data)
            case .failure(let error):
                switch error {
                case let appError as AppError where appError == AppError.registrationRequired:
                    self.register()
                    /*
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("Aceptar", action: {
                        self.register()
                    })
                    alert.showNotice("Bienvenido", subTitle: "Antes de continuar es necesario que complete el registro.")
                    */
                default:
                    self.notify(error: error)
                }
            }
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
        self.passText.text = ""
        let alert = self.showSpinner(withMessage: "Comprobando credenciales...")
        self.service.signIn(withEmail: email, password: pass) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                if self?.rememberCheckBox.checkState == .checked {
                    UserDefaults.standard.set(email, forKey: "user")
                }
                self?.login(withAccount: $0)
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        self.register()
    }
    
    func register() {
        self.performSegue(withIdentifier: "registerStudent", sender: self)
        /*
        let title = "Registrarse"
        let message = "¿Qué tipo de cuenta desea crear?"
        let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Registrar Profesor", style: .default) { action in
            self.performSegue(withIdentifier: "registerProfessor", sender: self)
        })
        controller.addAction(UIAlertAction(title: "Registrar Estudiante", style: .default) { action in
            self.performSegue(withIdentifier: "registerStudent", sender: self)
        })
        controller.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            let bounds = self.view.bounds
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(controller, animated: true)
         */
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

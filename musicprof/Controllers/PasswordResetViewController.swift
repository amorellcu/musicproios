//
//  PasswordResetViewController.swift
//  musicprof
//
//  Created by John Doe on 6/28/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class PasswordResetViewController: UIViewController, LoginController {
    
    var email: String!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeTextField.attributedPlaceholder = NSAttributedString(string: codeTextField.placeholder ?? "",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder ?? "",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
        passwordConfirmationTextField.attributedPlaceholder = NSAttributedString(string: passwordConfirmationTextField.placeholder ?? "",
                                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIViewController.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let alert = self.showSpinner(withMessage: "Enviando código de verificación...")
        self.service.sendResetCode(toEmail: self.email) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result)
        }
        
        self.validate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
         let userInfo = notification.userInfo!
         
         let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
         
         if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
         } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
         }
    }
    
    func validate() {
        self.confirmButton.isEnabled =
            !(self.codeTextField.text ?? "").isEmpty &&
            !(self.passwordTextField.text ?? "").isEmpty &&
            !(self.passwordConfirmationTextField.text ?? "").isEmpty &&
            self.passwordTextField.text == self.passwordConfirmationTextField.text
    }
    
    @IBAction func onResetPassword(_ sender: Any) {
        let password = self.passwordTextField.text ?? ""
        let code = self.codeTextField.text ?? ""
        let alert = self.showSpinner(withMessage: "Cambiando contraseña...")
        self.service.resetPassword(forUser: self.email, password: password, code: code) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                guard let strongSelf = self else { return }
                if strongSelf.service.isSignedIn {
                    strongSelf.login(withAccount: strongSelf.service.user!)
                } else {
                    strongSelf.service.signIn(withEmail: strongSelf.email, password: password, handler: { (result) in
                        self?.handleResult(result) {
                            self?.login(withAccount: $0)
                        }
                    })
                }
            }
        }
    }

}

extension PasswordResetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.validate()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validate()
    }
}

//
//  PasswordResetViewController.swift
//  musicprof
//
//  Created by John Doe on 6/28/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class PasswordResetViewController: UIViewController {
    
    var email: String!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIViewController.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        self.showSpinner(onView: self.view)
        self.service.sendResetCode(toEmail: self.email) { (result) in
            self.removeSpinner()
            self.handleResult(result)
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
        self.showSpinner(onView: self.view)
        self.service.resetPassword(forUser: self.email, password: password, code: code) { (result) in
            self.removeSpinner()
            self.handleResult(result) {
                if self.service.isSignedIn {
                    self.performSegue(withIdentifier: "login", sender: sender)
                } else {
                    self.service.signIn(withEmail: self.email, password: password, handler: { (result) in
                        self.handleResult(result) {
                            self.performSegue(withIdentifier: "login", sender: sender)
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

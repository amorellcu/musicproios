//
//  PasswordUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 7/2/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class PasswordUpdateViewController: BaseNestedViewController, RegistrationController, InputController {
    var user: User!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.preferredDisplayMode = .picture
        super.viewWillAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    open func validateFields() -> String? {
        let password = self.passwordTextField.text ?? ""
        let passwordConfirmation = self.passwordConfirmationTextField.text ?? ""
        if password.isEmpty && passwordConfirmation.isEmpty {
            return nil
        }
        guard !password.isEmpty else {
            return "Por favor, introduce la contraseña."
        }
        guard !passwordConfirmation.isEmpty else {
            return "Por favor, repite la contraseña."
        }
        guard passwordConfirmation == password else {
            return "Las contraseñas no coinciden."
        }
        return nil
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView?.contentInset = UIEdgeInsets.zero
        } else {
            scrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? RegistrationController {
            controller.user = self.user
        }
        if let controller = segue.destination as? NestedController {
            controller.container = self.container
        }
    }
}

extension PasswordUpdateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

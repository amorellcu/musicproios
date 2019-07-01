//
//  ContactInfoViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ContactInfoViewController: UIViewController, RegistrationController, NestedController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView?
    
    var container: ContainerViewController?
    
    open var client: Client! = Client()
    
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
        super.viewWillAppear(animated)
        self.container?.setDisplayMode(.picture, animated: true)
        self.updateFields()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    open func updateFields() {
        self.nameTextField.text = self.client.name
        self.emailTextField.text = self.client.email
        self.phoneTextField.text = self.client.phone
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
    
    open func updateClient() {
        self.client.name = self.nameTextField.text ?? ""
        self.client.phone = self.phoneTextField.text
        self.client.email = self.emailTextField.text
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? RegistrationController {
            controller.client = self.client
        }
        if let controller = segue.destination as? NestedController {
            controller.container = self.container
        }
    }
}

extension ContactInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.updateClient()
    }
}

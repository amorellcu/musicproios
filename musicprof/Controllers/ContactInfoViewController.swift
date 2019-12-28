//
//  ContactInfoViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ContactInfoViewController: BaseNestedViewController, RegistrationController, InputController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField?
    @IBOutlet weak var addressTextField: UITextField?
    @IBOutlet weak var locationButton: UIButton?
    @IBOutlet weak var scrollView: UIScrollView?
    
    open var user: User! = Client()
    
    override var preferredDisplayMode: ContainerViewController.DisplayMode {
        return .picture
    }
    
    var client: Client! {
        get { return self.user as? Client }
        set { self.user = newValue }
    }
    
    var location: Location? {
        didSet {
            guard let locationButton = self.locationButton else { return }
            guard let location = self.location else {
                return locationButton.isHidden = true
            }
            locationButton.isHidden = false;
            locationButton.setTitle(location.description, for: .normal)
            self.client?.locationId = location.id
            self.client.location = location
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mapButton = UIBarButtonItem(title: "Abrir Mapa", style: .plain, target: self, action: #selector(openMap))
        //let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self.view, action: #selector(UIView.endEditing(_:)))
        //toolbar.items = [flexSpace, item]
        toolbar.items = [mapButton, flexSpace]
        toolbar.sizeToFit()
        
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: nameTextField.placeholder ?? "",
                                                                      attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder ?? "",
                                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
        self.phoneTextField?.attributedPlaceholder = NSAttributedString(string: phoneTextField?.placeholder ?? "",
                                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
        self.addressTextField?.attributedPlaceholder = NSAttributedString(string: addressTextField?.placeholder ?? "",
                                                                         attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
        
        self.addressTextField?.inputAccessoryView = toolbar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateFields()
        
        guard self.locationButton != nil else { return }
        if let location = self.client?.location {
            self.location = location
        } else if let locationId = self.client?.locationId, locationId != 0 {
            self.service.getLocation(withId: locationId) { [weak self] (result) in
                self?.handleResult(result) {
                    self?.location = $0
                }
            }
        } else {
            self.location = nil
        }
        
        //self.updateLocations()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    open func updateFields() {
        self.nameTextField.text = self.user.name
        self.emailTextField.text = self.user.email
        self.phoneTextField?.text = self.user.phone
        self.addressTextField?.text = self.user.address
        self.location = (self.user as? Client)?.location
    }
    
    open func validateFields() -> String? {
        guard let name = self.nameTextField.text, !name.isEmpty else {
            return "Por favor, introduce tu nombre."
        }
        guard let email = self.emailTextField.text, !email.isEmpty else {
            return "Por favor, introduce tu correo."
        }
        if let textField = self.phoneTextField, textField.text?.isEmpty ?? true {
            return "Por favor, introduce tu número telefónico."
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
    
    open func updateClient() {
        self.user.name = self.nameTextField.text ?? ""
        self.user.phone = self.phoneTextField?.text
        self.user.email = self.emailTextField.text
        self.user.address = self.addressTextField?.text ?? self.user.address
    }
    
    @objc func openMap() {
        self.performSegue(withIdentifier: "openMap", sender: nil)
    }
    
    private func updateLocations(completion: ((Location) -> ())? = nil) {
        guard self.locationButton != nil else { return }
        guard let address = self.user.address, !address.isEmpty else { return }
        let alert = self.showSpinner(withMessage: "Buscando ubicaciones...")
        self.service.getLocations(at: address) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result, onError: { _ in self?.location = nil }) { location in
                self?.location = location
                completion?(location)
            }
        }
    }
    
    @IBAction func onSelectLocation(_ sender: Any) {
        guard let address = self.client.address, !address.isEmpty else {
            SCLAlertView().showNotice("Acción inválida", subTitle: "Introduzca su dirección antes de seleccionar su ubicación.", closeButtonTitle: "Aceptar")
            return
        }
        self.updateLocations()
    }
    
    @IBAction func unwindToContactDetails(_ segue: UIStoryboardSegue) {
        
    }
    
    override func unwindBack(_ segue: UIStoryboardSegue) {
        if segue.identifier == "updateAddress", let controller = segue.source as? MapViewController {
            self.addressTextField?.text = controller.selectedAddress
            self.updateClient()
            guard self.locationButton != nil else { return }
            if let address = controller.selectedAddress, !address.isEmpty {
                self.updateLocations()
            }
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

extension ContactInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField === self.addressTextField && textField.text != self.user.address else { return }
        self.updateClient()
        self.updateLocations()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateClient()
        return true
    }
}

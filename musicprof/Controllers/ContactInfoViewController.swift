//
//  ContactInfoViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SCLAlertView

class ContactInfoViewController: BaseNestedViewController, RegistrationController, InputController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField?
    @IBOutlet weak var locationButton: UIButton?
    @IBOutlet weak var scrollView: UIScrollView?
    
    open var user: User! = Client()
    
    var client: Client! {
        get { return self.user as? Client }
        set { self.user = newValue }
    }
    
    var locations: [Location]?
    
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
        
        self.addressTextField?.inputAccessoryView = toolbar
        
        guard self.locationButton != nil else { return }
        if let location = self.client?.location {
            self.setLocation(location)
        } else if let locationId = self.client?.locationId {
            self.service.getLocation(withId: locationId) { [weak self] (result) in
                self?.handleResult(result) {
                    self?.setLocation($0)
                }
            }
        } else {
            let text = "Seleccionar Ubicación"
            self.locationButton?.setTitle(text, for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.preferredDisplayMode = .picture
        super.viewWillAppear(animated)
        self.updateFields()
        //self.updateLocations()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    open func updateFields() {
        self.nameTextField.text = self.user.name
        self.emailTextField.text = self.user.email
        self.phoneTextField.text = self.user.phone
        self.addressTextField?.text = self.user.address
        self.locationButton?.setTitle(self.client?.location?.description, for: .normal)
    }
    
    open func validateFields() -> String? {
        guard let name = self.nameTextField.text, !name.isEmpty else {
            return "Por favor, introduce tu nombre."
        }
        guard let email = self.emailTextField.text, !email.isEmpty else {
            return "Por favor, introduce tu correo."
        }
        guard let phone = self.phoneTextField.text, !phone.isEmpty else {
            return "Por favor, introduce tu número telefónico."
        }
        if let textField = self.addressTextField, (textField.text ?? "").isEmpty {
            return "Por favor, introduce tu dirección."
        }
        if self.locationButton != nil && self.client?.location == nil && self.client.locationId == nil {
            return "Por favor, selecciona tu ubicación."
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
        self.user.phone = self.phoneTextField.text
        self.user.email = self.emailTextField.text
        self.user.address = self.addressTextField?.text ?? self.user.address
    }
    
    @objc func openMap() {
        self.performSegue(withIdentifier: "openMap", sender: nil)
    }
    
    private func setLocation(_ location: Location) {
        self.client?.locationId = location.id
        self.locationButton?.setTitle(location.description, for: .normal)
    }
    
    private func showMapSelectionMenu(withOptions locations: [Location]) {
        let selection = locations.firstIndex(where: {$0.id == self.client?.locationId}) ?? 0
        ActionSheetStringPicker.show(withTitle: "Selecciona tu Ubicación", rows: locations, initialSelection: selection, doneBlock: { (_, index, location) in
            self.setLocation(locations[index])
        }, cancel: { (_) in
            
        }, origin: self.container ?? self)
    }
    
    private func updateLocations(completion: (([Location]) -> ())? = nil) {
        guard self.locationButton != nil else { return }
        guard let address = self.user.address, !address.isEmpty else { return }
        let alert = self.showSpinner(withMessage: "Buscando ubicaciones...")
        self.service.getLocations(at: address) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) { locations in
                self?.locations = locations
                completion?(locations)
            }
        }
    }
    
    @IBAction func onSelectLocation(_ sender: Any) {
        guard let address = self.client.address, !address.isEmpty else {
            SCLAlertView().showNotice("Acción inválida", subTitle: "Introduzca su dirección antes de seleccionar su ubicación.", closeButtonTitle: "Aceptar")
            return
        }
        if let locations = self.locations {
            switch locations.count {
            case 0:
                SCLAlertView().showNotice("Sin opciones", subTitle: "No se detectaron ubicaciones para su dirección", closeButtonTitle: "Aceptar")
            case 1:
                SCLAlertView().showNotice("Sin opciones", subTitle: "Se encontró solo una ubicación para su dirección", closeButtonTitle: "Aceptar")
            default:
                self.showMapSelectionMenu(withOptions: locations)
            }
        } else {
            self.updateLocations { [weak self] (locations) in
                if locations.count == 1 {
                    self?.setLocation(locations[0])
                } else if locations.count > 0 {
                    self?.showMapSelectionMenu(withOptions: locations)
                }
            }
        }
    }
    
    @IBAction func unwindToContactDetails(_ segue: UIStoryboardSegue) {
        
    }
    
    override func unwindBack(_ segue: UIStoryboardSegue) {
        if segue.identifier == "updateAddress", let controller = segue.source as? MapViewController {
            self.addressTextField?.text = controller.selectedAddress
            self.updateClient()
            guard self.locationButton != nil else { return }
            if let address = controller.selectedAddress, !address.isEmpty {
                self.updateLocations { [weak self] locations in
                    self?.locations = locations
                    if locations.count == 1 {
                        self?.setLocation(locations[0])
                    } else if locations.count > 0 {
                        self?.showMapSelectionMenu(withOptions: locations)
                    }
                }
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
        self.updateLocations { [weak self] locations in
            self?.locations = locations
            if locations.count == 1 {
                self?.setLocation(locations[0])
            } else if locations.count > 0 {
                self?.showMapSelectionMenu(withOptions: locations)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateClient()
        return true
    }
}

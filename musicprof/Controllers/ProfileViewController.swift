//
//  ProfileViewController.swift
//  musicprof
//
//  Created by John Doe on 6/22/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage
import SCLAlertView

class ProfileViewController: BaseReservationViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var selectForOtherButton: UIButton!
    
    @IBOutlet weak var selectForMeButton: UIButton!
    
    override var preferredDisplayMode: ContainerViewController.DisplayMode {
        return .full
    }
    
    override func loadView() {
        self.reservation = ReservationRequest()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "es-Es")
        self.reservation.calendar = calendar
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setTransparentBar()
        self.phoneTextField.keyboardType = .numberPad
        self.emailTextField.text = self.service.user?.email
        self.phoneTextField.text = self.service.user?.phone
        self.nameTextField.text = self.service.user?.name
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        guard let locationId = self.service.currentClient?.locationId, locationId != 0 else  {
            return SCLAlertView().showWarning("Ubicación desconocida", subTitle: "Por favor, introduzca su dirección antes de continuar.", closeButtonTitle: "Aceptar").setDismissBlock {
                self.menu?.gotoAccount()
                self.menu?.lockCurrentSection()
            }
        }
        
        if let credits = self.service.currentClient?.credits, credits == 0 {
            SCLAlertView().showWarning("Compre un paquete", subTitle: "Por favor, compre un paquete de clases antes de continuar.", closeButtonTitle: "Aceptar")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let locationId = self.service.currentClient?.locationId, locationId != 0 {
            self.selectForMeButton.isEnabled = true
            self.selectForOtherButton.isEnabled = true
        } else {
            self.selectForMeButton.isEnabled = false
            self.selectForOtherButton.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
        return true
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
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func unwindToReservation(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.selectForMeButton === sender as? UIButton {
            self.reservation.studentId = self.service.user!.id
            self.reservation.studentType = .account
            self.reservation.locationId = self.student?.locationId
        }
        super.prepare(for: segue, sender: sender)
    }

}

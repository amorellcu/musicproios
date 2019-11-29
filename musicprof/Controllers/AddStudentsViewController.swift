//
//  AddStudentsViewController.swift
//  musicprof
//
//  Created by John Doe on 6/23/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class AddStudentsViewController: BaseReservationViewController {
    weak var parentController: ReservationController!
    
    @IBOutlet weak var studentNameTextField: UITextField!
    @IBOutlet weak var continueButton: TransparentButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // Do any additional setup after loading the view.
        self.studentNameTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.studentNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.reservation.studentNames = [studentNameTextField.text ?? ""]
        self.reservation.locationId = self.service.currentClient?.locationId
        super.prepare(for: segue, sender: sender)
    }
}

extension AddStudentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.studentNameTextField.resignFirstResponder()
        if !(textField.text ?? "").isEmpty {
            self.performSegue(withIdentifier: "selectDate", sender: textField)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.continueButton.isEnabled = !(textField.text ?? "").isEmpty
    }
}


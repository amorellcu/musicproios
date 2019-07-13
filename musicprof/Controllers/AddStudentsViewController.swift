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
    override var reservation: ReservationRequest! {
        get { return parentController.reservation }
        set { parentController.reservation = newValue }
    }
    
    let prototypeCellIdentifier = "studentCell"
    var studentNames = [String]() {
        didSet {
            self.reservation.studentNames = self.studentNames
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var studentNameTextField: UITextField!
    @IBOutlet weak var addStudentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // Do any additional setup after loading the view.
        self.studentNameTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func onAddStudentTapped(_ sender: Any) {
        guard let name = self.studentNameTextField.text, !name.isEmpty else {
            return
        }
        self.studentNames.append(name)
        self.studentNameTextField.text = ""
        self.addStudentButton.isEnabled = false
    }
}

extension AddStudentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.studentNameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.addStudentButton.isEnabled = !(textField.text ?? "").isEmpty
        self.container?.setDisplayMode(.full, animated: true)
    }
}

extension AddStudentsViewController: StudentCellDelegate {
    func studentCell(_ cell: StudentCell, removeFrom path: IndexPath) {
        self.studentNames.remove(at: path.row)
    }
    
}

extension AddStudentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.prototypeCellIdentifier) as! StudentCell
        cell.nameLabel.text = self.studentNames[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}


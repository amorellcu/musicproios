//
//  AddStudentsViewController.swift
//  musicprof
//
//  Created by John Doe on 6/23/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class AddStudentsViewController: UIViewController {
    let prototypeCellIdentifier = "studentCell"
    var studentNames = [String]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var studentNameTextField: UITextField!
    @IBOutlet weak var addStudentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // Do any additional setup after loading the view.
        self.profileNameLabel.text = self.service.user?.name
        let placeholderAvatar = UIImage(named:"userdefault")
        if let avatarUrl = self.service.user?.avatarUrl {
            self.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: UIImage(named:"userdefault"))
        } else {
            self.avatarImageView.image = placeholderAvatar
        }
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.clipsToBounds = true
        self.studentNameTextField.delegate = self
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


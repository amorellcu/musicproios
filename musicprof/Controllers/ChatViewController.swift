//
//  ChatViewController.swift
//  musicprof
//
//  Created by John Doe on 7/10/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class ChatViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var professorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var instrumentImageView: UIImageView!
    @IBOutlet weak var professorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fullProfileConstriant: NSLayoutConstraint!
    @IBOutlet weak var textInputConstraint: NSLayoutConstraint!
    
    var theClass: Class?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setTransparentBar()
        self.titleLabel.text = ""
        self.professorLabel.text = self.theClass?.professor?.name
        self.setAvatar(self.service.user?.avatarUrl, for: self.avatarImageView)
        self.setAvatar(self.theClass?.professor?.avatarUrl, for: self.professorImageView)
        self.avatarImageView.clipsToBounds = true
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func setAvatar(_ url: URL?, for imageView: UIImageView) {
        let placeholderAvatar = UIImage(named:"userdefault")?.af_imageAspectScaled(toFit: imageView.frame.size).af_imageRoundedIntoCircle()
        if let avatarUrl = url {
            let filter = ScaledToSizeCircleFilter(size: imageView.frame.size)
            imageView.af_setImage(withURL: avatarUrl, placeholderImage: placeholderAvatar, filter: filter)
        } else {
            imageView.image = placeholderAvatar
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        //let userInfo = notification.userInfo!
        
        //let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            //self.setDisplayMode(.full, animated: true)
        } else {
            
        }
    }

    @IBAction func onSubmitTapped(_ sender: Any) {
        
    }
    
    @IBAction func onDetailsTapped(_ sender: Any) {
        
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError()
    }
}

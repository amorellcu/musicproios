//
//  ContactInfoUpdateViewController.swift
//  musicprof
//
//  Created by Jon Doe on 7/22/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class ContactInfoUpdateViewController: ContactInfoViewController {
    
    var imageImporter: ImageImporter!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func loadView() {
        imageImporter = ImageImporter(viewController: self)
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let avatarImageView = self.container?.avatarImageView {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onChangeAvatar))
            avatarImageView.addGestureRecognizer(gestureRecognizer)
            self.tapGestureRecognizer = gestureRecognizer
            self.tapGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tapGestureRecognizer?.isEnabled = true
        
        let image = UIImage(named: "change-avatar")
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onChangeAvatar))
        self.container?.avatarToolbar.setItems([buttonItem], animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tapGestureRecognizer?.isEnabled = false
        self.container?.avatarToolbar.setItems([], animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSaveChanges(_ sender: Any) {
        self.updateClient()
        let alert = self.showSpinner(withMessage: "Actualizando cambios...")
        self.service.updateProfile(self.client) { (result) in
            alert.hideView()
            self.handleResult(result) {
                self.client = $0
            }
        }
    }
        
    @objc func onChangeAvatar() {
        imageImporter.getPicture(for: self.user) { [weak self] in
            guard let url = self?.user?.avatarUrl, url.isFileURL else { return }
            self?.container?.avatarImageView.image = UIImage(contentsOfFile: url.path)?.af_imageRoundedIntoCircle()
        }
    }
}

//
//  RegisterStepOneViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 29/01/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import AlamofireImage

class ContactInfoRegistrationViewController: ContactInfoViewController {
    
    var imageImporter: ImageImporter!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var avatarToolbar: UIToolbar!    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func loadView() {
        imageImporter = ImageImporter(viewController: self)
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let avatarImageView = self.avatarImageView {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactInfoRegistrationViewController.onChangeAvatar))
            avatarImageView.addGestureRecognizer(gestureRecognizer)
            self.tapGestureRecognizer = gestureRecognizer
        }
        
        self.avatarToolbar.setTransparent()
        
        let image = UIImage(named: "change-avatar")
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onChangeAvatar))
        self.avatarToolbar.setItems([buttonItem], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if FBSDKAccessToken.current() == nil {
            self.updateFields()
        } else {
            self.user.loadFromFB { [weak self] (error) in
                if (error == nil) {
                    self?.updateFields()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func updateFields() {
        let placeholderAvatar = UIImage(named:"userdefault")
        if let avatarUrl = self.user.avatarUrl, avatarUrl.isFileURL {
            self.avatarImageView.image = UIImage(contentsOfFile: avatarUrl.path)
        } else if let avatarUrl = self.user.avatarUrl {
            let filter = AspectScaledToFillSizeCircleFilter(size: self.avatarImageView.frame.size)
            self.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: UIImage(named:"userdefault"), filter: filter) { response in
                if let avatar = response.result.value, let data = UIImagePNGRepresentation(avatar) {
                    let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                    let destinationURL = documentsPath.appendingPathComponent("\(UUID()).png")
                    if FileManager.default.createFile(atPath: destinationURL.path, contents: data, attributes: nil) {
                        self.user.avatarUrl = destinationURL
                    }
                }
            }
        } else {
            self.avatarImageView.image = placeholderAvatar?.af_imageAspectScaled(toFit: self.avatarImageView.frame.size).af_imageRoundedIntoCircle()
        }
        super.updateFields()
    }
    
    @objc func onChangeAvatar() {
        imageImporter.getPicture(for: self.user) { [weak self] in
            guard let url = self?.user?.avatarUrl, url.isFileURL else { return }
            self?.container?.avatarImageView.image = UIImage(contentsOfFile: url.path)?.af_imageRoundedIntoCircle()
        }
    }
}

class ClientContactInfoRegistrationViewController: ContactInfoRegistrationViewController, ClientRegistrationController {
    override func loadView() {
        self.client = Client()
        super.loadView()
    }
    
    @IBAction func onRegisterSubaccounts(_ sender: Any) {
        self.updateClient()
        
        if let error = self.validateFields() {
            return self.notify(message: error, title: "Información incompleta")
        }
        
        self.client.instruments = []
        let alert = self.showSpinner(withMessage: "Creando la cuenta...")
        self.service.registerClient(self.client) { (result) in
            alert.hideView()
            self.handleResult(result) {
                self.client = $0
                self.performSegue(withIdentifier: "registerStudents", sender: sender)
            }
        }
    }
}

class ProfessorContactInfoRegistrationViewController: ContactInfoRegistrationViewController, ProfessorRegistrationController {
    var professor: Professor! {
        get { return self.user as? Professor }
        set { self.user = newValue }
    }
    
    override func loadView() {
        self.professor = Professor()
        super.loadView()
    }
    
    @IBAction func onRegisterTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "selectInstruments", sender: sender)
        /*
        self.updateClient()
        self.professor.instruments = []
        self.showSpinner(onView: self.view)
        self.service.registerProfessor(self.professor) { (result) in
            self.removeSpinner()
            self.handleResult(result) {
                self.professor = $0
                self.performSegue(withIdentifier: "register", sender: sender)
            }
        }
 */
    }
}

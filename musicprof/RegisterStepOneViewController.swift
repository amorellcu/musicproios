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

class RegisterStepOneViewController: UIViewController {

    @IBOutlet weak var perfil: UIImageView!
    
    @IBOutlet weak var namePerfil: UITextField!
    
    @IBOutlet weak var emailPerfil: UITextField!
    
    @IBOutlet weak var phonePerfil: UITextField!

    
    @IBAction func onCloseTapped(_ sender: UIButton) {
        self.onLogoutAction(activityIndicator: ai, closeIcon: iconClose)
    }
    
    @IBOutlet weak var iconClose: UIImageView!
    
    @IBOutlet weak var ai: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    var buttonclick: String = ""
    var facebookid: String = ""
    var photoUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if(self.photoUrl == ""){
            self.perfil.image = UIImage(named:"userdefault")
        }
        self.perfil.layer.cornerRadius = self.perfil.frame.size.width / 2
        self.perfil.clipsToBounds = true
        self.phonePerfil.keyboardType = .numberPad
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterStepOneViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    var dict = result as! [String : AnyObject]
                    var data = dict["picture"]!["data"] as! [String : AnyObject]
                    let imageUrlString = data["url"] as! String
                    let imageUrl:URL = URL(string: imageUrlString)!
                    self.photoUrl = imageUrlString
                    // Start background thread so that image loading does not make app unresponsive
                    DispatchQueue.global(qos: .userInitiated).async {
                        let imageData:NSData = NSData(contentsOf: imageUrl)!
                        // When from background thread, UI needs to be updated on main_queue
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData as Data)
                            self.perfil.image = image
                            self.namePerfil.text = dict["name"] as? String
                            self.emailPerfil.text = dict["email"] as? String
                            self.facebookid = (dict["id"] as? String)!
                           
                        }
                    }
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.namePerfil.resignFirstResponder()
        self.emailPerfil.resignFirstResponder()
        self.phonePerfil.resignFirstResponder()
        return true
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollview.contentInset = UIEdgeInsets.zero
        } else {
            scrollview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

    
    @IBAction func buttonAny(_ sender: Any) {
        //let student = Student()
        //if(self.perfil.image != nil)
        //{
        //     student.setPhoto(aphoto: self.perfil.image!)
        //}
        //if(self.namePerfil.text != nil)
        //{
        //    student.setName(aname: self.namePerfil.text!)
        //}
        //self.performSegue(withIdentifier: "instruments2Segue", sender: student)
    }
    
    
    @IBAction func buttonme(_ sender: Any) {
        /*
        let student = Student()
        if(self.perfil.image != nil)
        {
            student.setPhoto(aphoto: self.perfil.image!)
        }
        else{
            self.perfil.image = UIImage(named: "userdefault")
            student.setPhoto(aphoto: self.perfil.image!)
        }
        
        if(self.namePerfil.text != nil)
        {
            student.setName(aname: self.namePerfil.text!)
        }
        
        if(self.phonePerfil.text != nil)
        {
            student.setPhone(aphone: self.phonePerfil.text!)
        }
        
        if(self.facebookid != nil)
        {
            student.setFbId(afbid: self.facebookid)
        }
        if(self.emailPerfil.text != nil)
        {
            student.setEmail(aemail: self.emailPerfil.text!)
        }
        if(self.photoUrl != ""){
            student.setUrlPhoto(aurlphoto: self.photoUrl)
        }
 
        self.performSegue(withIdentifier: "instruments1Segue", sender: student)
    */
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*
        let student = sender as? Student
        let name = student?.getName()
        let photo = student?.getPhoto()
        let phone = student?.getPhone()
        let facebookid = student?.getFbId()
        let email = student?.getEmail()
        let photourl = student?.getUrlPhoto()
        if(segue.identifier == "instruments2Segue"){
            let Instruments = segue.destination as? InstrumentsViewController
            if(name != nil){
                Instruments?.namePerfil = name!
            }
            if(photo != nil){
                Instruments?.photoPerfil = photo!
            }
            if(phone != nil){
                Instruments?.phone = phone!
            }
            if(email != nil){
                Instruments?.emailPerfil = email!
            }
            if(facebookid != nil){
                Instruments?.facebookid = facebookid!
            }
            if(photourl != nil){
                Instruments?.photoUrl = photourl!
            }
        }
        else{
            let Instruments = segue.destination as? InstrumentsmeViewController
            if(name != nil){
                Instruments?.namePerfil = name!
            }
            if(photo != nil){
                Instruments?.photoPerfil = photo!
            }
            if(phone != nil){
                Instruments?.phone = phone!
            }
            if(email != nil){
             Instruments?.emailPerfil = email!
             }
            if(facebookid != nil){
                Instruments?.facebookid = facebookid!
            }
            if(photourl != nil){
                Instruments?.photoUrl = photourl!
            }
        }
        
*/

    }
    

}

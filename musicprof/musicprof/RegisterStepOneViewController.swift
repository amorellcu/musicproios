//
//  RegisterStepOneViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 29/01/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
extension UITextField {
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit

class RegisterStepOneViewController: UIViewController {

    @IBOutlet weak var perfil: UIImageView!
    
    @IBOutlet weak var namePerfil: UITextField!
    
    @IBOutlet weak var emailPerfil: UITextField!
    
    @IBOutlet weak var phonePerfil: UITextField!

    
    @IBOutlet weak var scrollview: UIScrollView!
    var buttonclick: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    var dict = result as! [String : AnyObject]
                    var data = dict["picture"]!["data"] as! [String : AnyObject]
                    let imageUrlString = data["url"] as! String
                    let imageUrl:URL = URL(string: imageUrlString)!
                    
                    // Start background thread so that image loading does not make app unresponsive
                    DispatchQueue.global(qos: .userInitiated).async {
                        let imageData:NSData = NSData(contentsOf: imageUrl)!
                        // When from background thread, UI needs to be updated on main_queue
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData as Data)
                            self.perfil.image = image
                            self.namePerfil.text = dict["name"] as? String
                            self.emailPerfil.text = dict["email"] as? String
                        }
                    }
                }
            })
        }
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
        let student = Student()
        if(self.perfil.image != nil)
        {
             student.setPhoto(aphoto: self.perfil.image!)
        }
        if(self.namePerfil.text != nil)
        {
            student.setName(aname: self.namePerfil.text!)
        }
        self.performSegue(withIdentifier: "instruments2Segue", sender: student)
    }
    
    
    @IBAction func buttonme(_ sender: Any) {
        let student = Student()
        if(self.perfil.image != nil)
        {
            student.setPhoto(aphoto: self.perfil.image!)
        }
        if(self.namePerfil.text != nil)
        {
            student.setName(aname: self.namePerfil.text!)
        }
        self.performSegue(withIdentifier: "instruments1Segue", sender: student)
    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let student = sender as? Student
        let name = student?.getName()
        let photo = student?.getPhoto()
        if(segue.identifier == "instruments2Segue"){
            let Instruments = segue.destination as? InstrumentsViewController
            if(name != nil){
                Instruments?.namePerfil = name!
            }
            if(photo != nil){
                Instruments?.photoPerfil = photo!
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
        }
        


    }
    

}

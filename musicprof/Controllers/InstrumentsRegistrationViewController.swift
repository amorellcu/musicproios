//
//  InstrumentsViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 08/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage
import SCLAlertView

class InstrumentsRegistrationViewController: InstrumentListViewController {
    
    var editClient: Client?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var studentNameTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.nameLabel.text = self.client.name
        let placeholderAvatar = UIImage(named:"userdefault")
        if let avatarUrl = self.client.avatarUrl {
            let filter = ScaledToSizeCircleFilter(size: self.avatarImageView.frame.size)
            self.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: UIImage(named:"userdefault"), filter: filter)
        } else {
            self.avatarImageView.image = placeholderAvatar?.af_imageAspectScaled(toFit: self.avatarImageView.frame.size).af_imageRoundedIntoCircle()
        }
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.clipsToBounds = true
        self.studentNameTextField?.text = self.editClient?.name ?? ""
        self.studentNameTextField?.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIViewController.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateInstruments() {
        self.service.getInstruments { [weak self] (result) in
            self?.handleResult(result) { values in
                self?.instruments = values
                
                if let selectedValues = self?.editClient?.instruments {
                    for i in 0..<values.count {
                        if selectedValues.contains(values[i]) {
                            let indexPath = IndexPath(item: i, section: 0)
                            self?.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                        }
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        /*
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollview.contentInset = UIEdgeInsets.zero
        } else {
            scrollview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
         */
    }
    
    func reset() {
        self.studentNameTextField?.text = ""
        self.collectionView.selectItem(at: nil, animated: true, scrollPosition: .top)
    }
    
    @IBAction func onRegisterSubbacount(_ sender: Any) {
        let instruments = self.instruments ?? []
        let selection = self.collectionView.indexPathsForSelectedItems ?? []
        
        let client = Client()
        client.userId = self.client.id
        client.name = self.studentNameTextField?.text ?? ""
        client.instruments = selection.map({instruments[$0.item]})
        
        self.service.registerSubaccount(client) { (result) in
            self.handleResult(result) {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("SI") {
                    self.reset()
                }
                alertView.addButton("NO") {
                    self.performSegue(withIdentifier: "login", sender: sender)
                }
                alertView.showSuccess("El estudiante \(self.studentNameTextField?.text ?? "") se ha agregado correctamente", subTitle: "¿Desea Agregar otro estudiante?")
            }
        }
    }
    
    @IBAction func onUpdateSubbacount(_ sender: Any) {
        let instruments = self.instruments ?? []
        let selection = self.collectionView.indexPathsForSelectedItems ?? []
        
        let client = self.editClient!
        client.name = self.studentNameTextField?.text ?? ""
        client.instruments = selection.map({instruments[$0.item]})
        
        self.service.updateSubaccount(client) { (result) in
            self.handleResult(result) {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("Aceptar") {
                    self.performSegue(withIdentifier: "login", sender: sender)
                }
                alertView.showSuccess("Estudiante actualizado", subTitle: "El estudiante \(self.studentNameTextField?.text ?? "") se actualizó correctamente")
            }
        }
    }
    
    @IBAction func onRegister(_ sender: Any) {
        let instruments = self.instruments ?? []
        let selection = self.collectionView.indexPathsForSelectedItems ?? []
        self.client.instruments = selection.map({instruments[$0.item]})
        
        self.service.registerClient(self.client) { (result) in
            self.handleResult(result) {
                let message = self.client.facebookId == nil ?
                    "Esperamos que disfrute la experiencia de nuestra aplicación" :
                "Se le enviará un mail con los datos correspondientes para acceder a la aplicación"
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView1 = SCLAlertView(appearance: appearance)
                alertView1.addButton("OK") {
                    self.performSegue(withIdentifier: "login", sender: sender)
                }
                alertView1.showSuccess("Gracias por Registrarte", subTitle: message)
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? PasswordResetViewController {
            controller.email = self.client.email
        }
    }
}

extension InstrumentsRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

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

@IBDesignable extension UILabel {
    
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



class InstrumentsViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    let alertView = SCLAlertView()
    let prototypeCellIdentifier = "instrumentCell"
    var instruments: [Instrument] = []
    var selectedInstrument: Int = -1
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.instruments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: prototypeCellIdentifier, for: indexPath) as! InstrumentCollectionViewCell
        let icon = instruments[indexPath.item].icon
        /////
        self.api.getAllInstruments() { json, error  in
            
            if(error != nil){
                self.alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor") // Error
            }
            else{
                let JSON = json! as NSDictionary
                if(String(describing: JSON["result"]!) == "Error"){
                    self.alertView.showError("Error Instrumentos", subTitle: String(describing: JSON["message"]!)) // Error
                } else if(String(describing: JSON["result"]!) == "OK"){
                    let data = JSON["data"] as? [String: Any]
                    let instruments = data!["instruments"] as! NSArray
                    for instrument in instruments {
                        var item = instrument as? [String: Any]
                        if(item!["icono"] as! String != ""){
                            let instrumentItem = Item(name:item!["name"]! as! String,icon:item!["icono"]! as! String,id:item!["id"]! as! Int)
                            self.instruments_items.append(instrumentItem)
                            
                        }
                        
                    }
                    self.tableview.reloadData()
                }
            }
        }
        /////
        if selectedInstrument == indexPath.item {
            let templateImage = icon.image?.withRenderingMode(.alwaysTemplate)
            icon.image = templateImage
            icon.tintColor = UIColor.white
        }
        
        cell.instrumentIcon.image = icon.image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedInstrument = indexPath.item
    }

    
    var namePerfil: String!
    var photoPerfil: UIImage!
    var facebookid: String = ""
    var phone: String = ""
    var instrumentsid: [Int] = []
    var emailPerfil: String!
    var photoUrl: String!
    
    @IBOutlet weak var perfilImage: UIImageView!
    @IBOutlet weak var PerfilName: UILabel!

    @IBOutlet weak var scrollview: UIScrollView!
    
//    let instruments_items:[Item] = [Item(name:"Canto",icon:"canto"), Item(name:"Guitarra Clásica",icon:"guitarra"), Item(name:"Guitarra Eléctrica",icon:"guitarraelectrica"), Item(name:"Trombon",icon:"trombon"), Item(name:"Saxofón",icon:"saxofon"), Item(name:"Trompeta",icon:"trompeta")]
    
    
    @IBOutlet weak var editname: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSpinner(onView: self.view)
        
        // Do any additional setup after loading the view.
        self.PerfilName.text = namePerfil
        self.perfilImage.image = photoPerfil
        self.perfilImage.layer.cornerRadius = self.perfilImage.frame.size.width / 2
        self.perfilImage.clipsToBounds = true
        self.editname.delegate = self
        //tableview.delegate = self
        //tableview.dataSource = self
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.editname.resignFirstResponder()
        return true
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return instruments_items.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UsersTableViewCell
//        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
//        cell.labelcell.text = instruments_items[indexPath.row].name
//        cell.iconcell.image = UIImage(named: instruments_items[indexPath.row].icon)
//        cell.cellswitch.setOn(instruments_items[indexPath.row].swith, animated: true)
//        return cell
//
//    }
    
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
    

    @IBAction func AddStudents(_ sender: Any) {

        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("SI") {
            self.editname.text = ""
            //self.tableview.reloadData()
        }
        alertView.addButton("NO") {

        }
        alertView.showSuccess("El estudiante \(String(describing: self.editname.text!)) se ha agregado correctamente", subTitle: "¿Desea Agregar otro estudiante?")
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

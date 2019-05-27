//
//  InstrumentsmeViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 11/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView
import Alamofire

class InstrumentsmeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var namePerfil: String!
    var photoPerfil: UIImage!
    var facebookid: String = ""
    var phone: String = ""
    let apimusicprof = ApiStudent.sharedInstance
    let alertView = SCLAlertView()
    var instrumentsid: [Int] = []
    var emailPerfil: String!
    var photoUrl: String! = ""
    
    @IBOutlet weak var perfilImage: UIImageView!
    @IBOutlet weak var PerfilName: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    struct Item {
        var name: String
        var icon: String
        var swith: Bool
        var id:Int
        
        init(name: String, icon: String, swith: Bool = false, id:Int) {
            self.name = name
            self.icon = icon
            self.swith = false
            self.id = id
        }
    }
    var instruments_items:[Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.PerfilName.text = namePerfil
        self.perfilImage.image = photoPerfil
        self.perfilImage.layer.cornerRadius = self.perfilImage.frame.size.width / 2
        self.perfilImage.clipsToBounds = true
        tableview.delegate = self
        tableview.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instruments_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UsersTableViewCell
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
        cell.labelcell.text = instruments_items[indexPath.row].name
        let url = URL(string: instruments_items[indexPath.row].icon)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                //cell.iconcell.image = UIImage(data: data!)
            }
        }
        cell.idinstrument = instruments_items[indexPath.row].id
        cell.cellswitch.setOn(instruments_items[indexPath.row].swith, animated: true)
        if(cell.status == 1){
            self.instrumentsid.append(cell.idinstrument)
            cell.cellswitch.setOn(true, animated: true)
        }
        else{
            if let index = self.instrumentsid.index(of: cell.idinstrument) {
                self.instrumentsid.remove(at: index)
            }
            cell.cellswitch.setOn(false, animated: true)
        }
        return cell
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apimusicprof.getAllInstruments() { json, error  in
            
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
        
    
    }

    
    @IBAction func onContinue(_ sender: Any) {
        self.tableview.reloadData()
        for cell in self.tableview.visibleCells {
            //print(cell)
        }
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let parameters = [
            "photo": self.photoUrl!,
            "email": self.emailPerfil!,
            "name": self.PerfilName.text!,
            "phone": self.phone,
            "coloniaId": "0",
            "address": "",
            "paymentTypeId": "1",
            "instruments": self.instrumentsid,
            "facebookID": self.facebookid
            ] as [String : Any]

        /*request("\(configuration.urlapi)/registerClient", method: .post, parameters:parameters,headers: headers).responseString { response in
            print(response)
        }*/
        apimusicprof.setHeaders(aheader: headers)
        apimusicprof.setParams(aparams: parameters)
        apimusicprof.registrarCliente() { json, error  in
            if(error != nil){
                self.alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor") // Error
            }
            else{
                let JSON = json! as NSDictionary
                if(String(describing: JSON["result"]!) == "Error"){
                    self.alertView.showError("Error Autenticación", subTitle: String(describing: JSON["message"]!)) // Error
                } else if(String(describing: JSON["result"]!) == "OK"){
                    var messageclient = ""
                    if(self.facebookid != ""){
                        messageclient = "espero disfrute la experiencia de nuestra aplicación"
                    }
                    else{
                        messageclient = "Se le enviará un mail con los datos correspondientes para acceder a la aplicación"
                    }
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView1 = SCLAlertView(appearance: appearance)
                    alertView1.addButton("OK") {
                        self.performSegue(withIdentifier: "homeSegue", sender: self)
                    }
                    alertView1.showSuccess("Gracias por Registrarte", subTitle: messageclient)
                }
            }
        }

        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*if(segue.identifier == "instrumentsUbicacionSegue"){
            let MapKit = segue.destination as? MapViewController
            MapKit?.namePerfil = self.namePerfil
            MapKit?.photoPerfil = self.photoPerfil
            MapKit?.facebookid = self.facebookid
            MapKit?.instrumentsid = self.instrumentsid
        }*/
        
        
        
    }

}

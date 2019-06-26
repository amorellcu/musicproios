//
//  scheduleViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 19/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var perfil: UIImageView!
    @IBOutlet weak var namePerfil: UILabel!
    var Perfilname: String!
    var photoPerfil: UIImage!
    let apimusicprof = ApiStudent.sharedInstance
    let alertView = SCLAlertView()
    var user: NSDictionary = [:]
    var instrumentsid: Int = 0
    var client: NSDictionary = [:]
    var dateclass: Date = Date()
    var address = ""
    
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
    
    //let instruments_items:[Item] = [Item(name:"Canto",icon:"canto"), Item(name:"Guitarra Clásica",icon:"guitarra")]
    var instruments_items:[Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.perfil.image = photoPerfil
        self.namePerfil.text = Perfilname
        self.perfil.layer.cornerRadius = self.perfil.frame.size.width / 2
        self.perfil.clipsToBounds = true
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UsersTableViewCell
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
        cell.labelcell.text = instruments_items[indexPath.row].name
        let url = URL(string: instruments_items[indexPath.row].icon)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.iconcell.image = UIImage(data: data!)
            }
        }
        cell.idinstrument = instruments_items[indexPath.row].id
        if(cell.status == 1){
            self.instrumentsid = cell.idinstrument
            cell.cellswitch.setOn(true, animated: true)
        } else {
            //cell.cellswitch.setOn(false, animated: true)
        }
        return cell
    }
    

    @IBAction func fixLocations(_ sender: Any) {
        self.performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    
    @IBAction func goSchedule(_ sender: Any) {
        self.tableview.reloadData()
        var countstatus = 0
        for cell1 in self.tableview.visibleCells {
            let cell2 = cell1 as! UsersTableViewCell
            
            if(cell2.status == 1){
                countstatus += 1
            }
            //print(cell2.status)
        }
        let data = self.client["data"] as? [String: Any]
        let client = data!["client"] as? [String: Any]
        let address = client!["address"]! as! String
        //print(address)
        if(self.instrumentsid == 0){
            let alertView1 = SCLAlertView()
            alertView1.showError("Error de Datos", subTitle: "Debes seleccionar el instrumento de la clase")
        }else if(countstatus > 1){
            let alertView1 = SCLAlertView()
            alertView1.showError("Error de Datos", subTitle: "Debes seleccionar un solo instrumento para la clase")
        }else if(address == ""){
            let alertView1 = SCLAlertView()
            alertView1.showError("Error de Datos", subTitle: "Debes fijar la ubicación donde se impartirá la clase")
        }
        else{
           self.performSegue(withIdentifier: "horarioSegue", sender: self)
        }
        //
    }
    
    
    
    
     // MARK: - Navigation    
    
    override func viewWillAppear(_ animated: Bool) {
        self.instruments_items = []
        let data = self.user["data"] as? [String: Any]
        let client = data!["client"] as? [String: Any]
        let address = client!["address"]! as! String
        self.address = address
        let headers = [
            "Authorization": "Bearer \(data!["token"]! as! String)",
            "X-Requested-With": "XMLHttpRequest"
        ]
        let parameters = [
            "id": client!["users_id"]! as! Int
        ]
        apimusicprof.setHeaders(aheader: headers)
        apimusicprof.setParams(aparams: parameters)
        apimusicprof.getClient() { json, error  in
            if(error != nil){
                self.alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor") // Error
            }
            else{
                let JSON = json! as NSDictionary
                if(String(describing: JSON["result"]!) == "Error"){
                    self.alertView.showError("Error Obteniendo usuario", subTitle: String(describing: JSON["message"]!)) // Error
                } else if(String(describing: JSON["result"]!) == "OK"){
                    self.client = JSON
                    if(self.user == nil){
                        self.alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor")
                    }
                    else{
                        let data = self.client["data"] as? [String: Any]
                        let client = data!["client"] as? [String: Any]
                        let address = client!["address"]! as! String
                        self.address = address
                        let instruments = client!["instruments"] as! NSArray
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

        
        
    }


}

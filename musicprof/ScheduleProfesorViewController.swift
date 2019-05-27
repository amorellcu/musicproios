//
//  ScheduleProfesorViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 23/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView
import Alamofire

class ScheduleProfesorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var perfil: UIImageView!
    @IBOutlet weak var namePerfil: UILabel!
    
    @IBOutlet weak var tableview: UITableView!
    var Perfilname: String!
    var photoPerfil: UIImage!
    var dateclass: Date = Date()
    var address = ""
    let apimusicprof = ApiStudent.sharedInstance
    var user: NSDictionary = [:]
    var instrumenid = 0
    
    struct Item {
        var name: String
        var photo: String
        var votes: Int
        
        init(name: String, photo: String, votes: Int = 0) {
            self.name = name
            self.photo = photo
            self.votes = votes
        }
    }
    
    struct Section {
        var name: String
        var items: [Item]
        var collapsed: Bool
        var textcolor: UIColor
        
        init(name: String, items: [Item], collapsed: Bool = true, textcolor: UIColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1), leftrow: String = "flechaizq", rightrow: String = "flechader") {
            self.name = name
            self.items = items
            self.collapsed = collapsed
            self.textcolor = textcolor
        }
    }
    
    var sections = [Section]()
    var schedules: [String] = ["09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00"]
    var profesors: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.perfil.image = photoPerfil
        self.namePerfil.text = Perfilname
        self.perfil.layer.cornerRadius = self.perfil.frame.size.width / 2
        self.perfil.clipsToBounds = true
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.getProfesors()
        sections = [
            Section(name: "9:00 AM", items: [Item(name:"Alexis Morell",photo:"profesor")],collapsed: true),
            Section(name: "10:00 AM", items: [Item(name:"Alejandro Ruiz",photo:"profesor"), Item(name:"Dayana Machin",photo:"profesor")],collapsed: true),
            Section(name: "11:00 AM", items: [Item(name:"Alejandro Ruiz",photo:"profesor"), Item(name:"Alexis Morell",photo:"profesor")],collapsed: true),
        ]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if section == 0 {
            return 1
        }
        
        // For section 1, the total count is items count plus the number of headers
        count = sections.count
        
        for section in sections {
            count += section.items.count
        }
        return count

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:  return ""
        case 1:  return ""
        default: return ""
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 0
        }
        
        // Calculate the real section index and row index
        let section = getSectionIndex(indexPath.row)
        let row = getRowIndex(indexPath.row)
        var height: CGFloat
        
        // Header has fixed height
        if row == 0 {
            return 55.0
        }
        if(section == 0){
            height = 55.0
        }
        else{
            height = 52.0
        }
        
        return sections[section].collapsed ? 0 : height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title") as UITableViewCell!
            cell?.textLabel?.text = ""
            cell?.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell!
        }
        // Calculate the real section index and row index
        let section = getSectionIndex(indexPath.row)
        let row = getRowIndex(indexPath.row)
        let collapsed = sections[section].collapsed
        
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! HeaderTableViewCell
            cell.titleLabel.text = sections[section].name
            if(!collapsed){
                cell.titleLabel.textColor = UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1)
                cell.titleLabel.backgroundColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
            }
            cell.togglebutton.tag = section
            cell.togglebutton.setTitle(sections[section].collapsed ? "+" : "-", for: UIControlState())
            cell.togglebutton.addTarget(self, action: #selector(ScheduleProfesorViewController.toggleCollapse), for: .touchUpInside)
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProfesorTableViewCell!
            cell?.profesorName.text = sections[section].items[row - 1].name
            cell?.profesorImage.image = UIImage(named: sections[section].items[row - 1].photo)
            cell?.profesorImage.layer.cornerRadius = (cell?.profesorImage.frame.size.width)! / 2
            cell?.profesorImage.clipsToBounds = true
            cell?.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = getSectionIndex(indexPath.row)
        let row = getRowIndex(indexPath.row)
        let name = sections[section].items[row - 1].name
        
        self.performSegue(withIdentifier: "profesorDetailSegue", sender: name)
    }
    
    func getSectionIndex(_ row: NSInteger) -> Int {
        let indices = getHeaderIndices()
        
        for i in 0..<indices.count {
            if i == indices.count - 1 || row < indices[i + 1] {
                return i
            }
        }
        
        return -1
    }
    
    func getRowIndex(_ row: NSInteger) -> Int {
        var index = row
        let indices = getHeaderIndices()
        
        for i in 0..<indices.count {
            if i == indices.count - 1 || row < indices[i + 1] {
                index -= indices[i]
                break
            }
        }
        
        return index
    }
    
    func getHeaderIndices() -> [Int] {
        var index = 0
        var indices: [Int] = []
        
        for section in sections {
            indices.append(index)
            index += section.items.count + 1
        }
        
        return indices
    }
    
    @objc func toggleCollapse(_ sender: UIButton) {
        let section = sender.tag
        let collapsed = sections[section].collapsed
        // Toggle collapse
        sections[section].collapsed = !collapsed
        
        let indices = getHeaderIndices()
        
        let start = indices[section]
        let end = start + sections[section].items.count
        
        self.tableview.beginUpdates()
        for i in start ..< end + 1 {
            self.tableview.reloadRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
        }
        self.tableview.endUpdates()
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "profesorDetailSegue"){
            let profesorDetail = segue.destination as? ProfesorDetailViewController
            let name = sender as? String
            profesorDetail?.Perfilname = name
            
        }
    }
    
    func getProfesors(){
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let classdate = dateFormatterGet.string(from: self.dateclass)
        let parameters = [
            "address": self.address
        ]
        apimusicprof.setParams(aparams: parameters)
        /*let url = "\(configuration.urlapi)/getSublocality?address=\(parameters["address"]!)"
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        request(encodedUrl!, method: .get).responseString { response in
         print(response)
        }*/
        apimusicprof.getColony() { json, error  in
            if(error != nil){
                self.showerrorProfesor()
            } else {
                let JSON = json! as NSDictionary
                if(String(describing: JSON["result"]!) == "OK"){
                    let data1 = JSON["data"]! as! [String:Any]
                    let colony = data1["colonia"]! as! NSArray
                    if(colony.count > 0){
                        
                        let colonybd = colony[0] as! [String:Any]
                        let datauser = self.user["data"] as? [String: Any]
                        let headers = [
                            "Authorization": "Bearer \(datauser!["token"]! as! String)",
                            "X-Requested-With": "XMLHttpRequest"
                        ]
                        let parameters1 = [
                            "coloniaId": colonybd["id"] as! Int,
                            "instrumentId": self.instrumenid,
                            "classDate":classdate
                            ] as [String : Any]
                        
                        self.apimusicprof.setHeaders(aheader: headers)
                        self.apimusicprof.setParams(aparams: parameters1)
                        /*request("\(configuration.urlapi)/getAvailableProfesorsOnDate1?coloniaId=\(parameters1["coloniaId"]!)&instrumentId=\(parameters1["instrumentId"]!)&classDate=\(parameters1["classDate"]!)", method: .get,headers: headers).responseString { response in
                         print(response)
                         }*/
                        self.apimusicprof.getScheduleProfesor() { json, error  in
                            if(error != nil){
                                
                            }
                            else{
                                let JSON = json! as NSDictionary
                                let data = JSON["data"]! as! [String:Any]
                                let hours = data["hours"]! as! NSArray
                                self.profesors = hours
                            }
                            if(self.profesors.count == 0){
                                self.showerrorProfesor()
                            }
                            else{
                                print(self.profesors)
                            }
                        }
                    } else {
                        self.showerrorProfesor()
                    }
                } else {
                    self.showerrorProfesor()
                }
            }
        }

    }
    
    func showerrorProfesor(){
        let appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
        )
        let alertView1 = SCLAlertView(appearance: appearance)
        alertView1.addButton("OK") {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        }
        alertView1.showError("No se encontraron Profesores", subTitle: "No hay disponibilidad para la dirección \(self.address) intente fijar otra ubicación")
    }

}

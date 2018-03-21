//
//  ScheduleProfesorViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 23/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ScheduleProfesorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var perfil: UIImageView!
    @IBOutlet weak var namePerfil: UILabel!
    
    @IBOutlet weak var tableview: UITableView!
    var Perfilname: String!
    var photoPerfil: UIImage!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.perfil.image = photoPerfil
        self.namePerfil.text = Perfilname
        self.perfil.layer.cornerRadius = self.perfil.frame.size.width / 2
        self.perfil.clipsToBounds = true
        self.tableview.delegate = self
        self.tableview.dataSource = self
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
            //if(self.perfil != nil){
                //profesorDetail?.photoPerfil = self.perfil.image
            //}
            
        }
    }

}

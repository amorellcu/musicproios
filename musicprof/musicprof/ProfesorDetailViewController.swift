//
//  ProfesorDetailViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 26/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ProfesorDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var namePerfil: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    var Perfilname: String!
    var photoPerfil: UIImage!
    
    
    struct Section {
        var name: String
        var items: [String]
        var collapsed: Bool
        var textcolor: UIColor
        var leftrow: String
        var rightrow: String
        
        init(name: String, items: [String], collapsed: Bool = true, textcolor: UIColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1), leftrow: String = "flechaizq", rightrow: String = "flechader") {
            self.name = name
            self.items = items
            self.collapsed = collapsed
            self.textcolor = textcolor
            self.leftrow = leftrow
            self.rightrow = rightrow
        }
    }
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.perfil.image = photoPerfil
        self.namePerfil.text = Perfilname
        sections = [
            Section(name: "RESEÑA PERSONAL", items: ["Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."],collapsed: false),
            Section(name: "EXPERIENCIA LABORAL", items: ["Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."],collapsed: true,textcolor: UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1),leftrow: "fleizqoff",rightrow: "flederoff"),
            Section(name: "FORMACIÓN ACADEMICA", items: ["Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."],collapsed: true,textcolor: UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1),leftrow: "fleizqoff",rightrow: "flederoff"),
        ]
        tableview.dataSource = self
        tableview.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        // For section 1, the total count is items count plus the number of headers
        var count = sections.count
        
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
            return 52.0
        }
        height = 200.0
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "header1") as! Header1TableViewCell
            cell.titleLabel.text = sections[section].name
            
            if(collapsed){
                cell.titleLabel.textColor = UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1)
                cell.imgizq.image = UIImage(named:"fleizqoff")
                cell.imgder.image = UIImage(named:"flederoff")
            }
            cell.togglebutton.tag = section
            cell.togglebutton.setTitle(sections[section].collapsed ? "+" : "-", for: UIControlState())
            cell.togglebutton.addTarget(self, action: #selector(ProfesorDetailViewController.toggleCollapse), for: .touchUpInside)
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TextTableViewCell!
            cell?.textlabel.text = sections[section].items[row - 1]
            cell?.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell!

        }
    }
    
    @objc func toggleCollapse(_ sender: UIButton) {
        let section = sender.tag
        if(sections.count > 1){
            if (section == 0) {
                sections[1].collapsed = true
                /*sections[1].textcolor = UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1)
                 sections[1].leftrow = "fleizqoff"
                 sections[1].rightrow = "flederoff"
                 self.tableview.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)*/
            } else {
                sections[0].collapsed = true
                /*sections[0].textcolor = UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1)
                 sections[0].leftrow = "fleizqoff"
                 sections[0].rightrow = "flederoff"
                 self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)*/
            }
        }
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

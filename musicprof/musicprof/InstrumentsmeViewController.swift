//
//  InstrumentsmeViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 11/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class InstrumentsmeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var namePerfil: String!
    var photoPerfil: UIImage!
    
    @IBOutlet weak var perfilImage: UIImageView!
    @IBOutlet weak var PerfilName: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    struct Item {
        var name: String
        var icon: String
        var swith: Bool
        
        init(name: String, icon: String, swith: Bool = false) {
            self.name = name
            self.icon = icon
            self.swith = false
        }
    }
    
    let instruments_items:[Item] = [Item(name:"Canto",icon:"canto"), Item(name:"Guitarra Clásica",icon:"guitarra"), Item(name:"Guitarra Eléctrica",icon:"guitarraelectrica"), Item(name:"Trombon",icon:"trombon"), Item(name:"Saxofón",icon:"saxofon"), Item(name:"Trompeta",icon:"trompeta")]
    
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
        cell.iconcell.image = UIImage(named: instruments_items[indexPath.row].icon)
        cell.cellswitch.setOn(instruments_items[indexPath.row].swith, animated: true)
        return cell
        
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

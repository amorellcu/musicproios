//
//  scheduleViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 19/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var perfil: UIImageView!
    @IBOutlet weak var namePerfil: UILabel!
    var Perfilname: String!
    var photoPerfil: UIImage!
    
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
    
    let instruments_items:[Item] = [Item(name:"Canto",icon:"canto"), Item(name:"Guitarra Clásica",icon:"guitarra")]
    
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
        cell.iconcell.image = UIImage(named: instruments_items[indexPath.row].icon)
        cell.cellswitch.setOn(instruments_items[indexPath.row].swith, animated: true)
        return cell
    }
    

    @IBAction func fixLocations(_ sender: Any) {
        /*let alert = UIAlertController(title: "Ubicación", message: "Desea usar su ubicación actual", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Si", style: .default, handler: { action in

        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            
        }))
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor.clear
        subview.isOpaque = false
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        self.present(alert, animated: true, completion: nil)*/
        self.performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    
    @IBAction func goSchedule(_ sender: Any) {
        self.performSegue(withIdentifier: "horarioSegue", sender: self)
    }
    
    
    
    
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "horarioSegue"){
            let Schedule = segue.destination as? ScheduleProfesorViewController
            if(self.namePerfil != nil){
                Schedule?.Perfilname = self.namePerfil.text
            }
            
            if(self.perfil != nil){
                Schedule?.photoPerfil = self.perfil.image
            }
            
        }
    }


}

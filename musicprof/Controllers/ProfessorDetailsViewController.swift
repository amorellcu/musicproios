//
//  ProfesorDetailViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 26/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ProfessorDetailsViewController: BaseReservationViewController  {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextProfessorButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    let expandedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    let collapsedColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
    
    var professors = [Professor]()
    var sections = [Section]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.perfil.image = photoPerfil
        self.nextProfessorButton.isEnabled = self.professors.count > 1
        self.updateProfessor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.container?.setDisplayMode(.collapsed, animated: animated)
    }
    
    private func updateProfessor() {
        guard let professor = self.reservation.professor else {
            self.nameLabel.text = nil
            self.avatarImageView.image = UIImage(named:"profedetails")
            self.sections = []
            self.confirmButton.isEnabled = false
            return
        }
        
        self.updateProfessor(professor)
        
        guard sections.count == 0 else { return }
        
        let alert = self.showSpinner(withMessage: "Buscando datos del profesor...")
        self.service.getProfessor(withId: professor.id) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) { value in
                self?.reservation.professor = value
                if let index = self?.professors.firstIndex(where: {value.id == $0.id}) {
                    self?.professors[index] = value
                }
                self?.updateProfessor(value)
            }
        }
    }
    
    private func updateProfessor(_ professor: Professor) {
        let placeholderAvatar = UIImage(named:"profedetails")
        self.nameLabel.text = professor.name
        if let avatarUrl = professor.avatarUrl {
            self.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: placeholderAvatar)
        } else {
            self.avatarImageView.image = placeholderAvatar
        }
        sections = [
            Section(name: "RESEÑA PERSONAL", items: professor.personalReview == nil || professor.personalReview!.isEmpty ? [] : [professor.personalReview!], collapsed: false),
            Section(name: "EXPERIENCIA LABORAL", items: professor.workExperience == nil || professor.workExperience!.isEmpty ? [] : [professor.workExperience!],collapsed: true),
            Section(name: "FORMACIÓN ACADEMICA", items: professor.academicTraining == nil || professor.academicTraining!.isEmpty ? [] : [professor.academicTraining!],collapsed: true),
            ].filter({$0.items.count > 0})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNextProfessorTapped(_ sender: UIButton) {
        guard professors.count > 0 else { return }
        var index = professors.firstIndex(where: {self.reservation.professor === $0}) ?? 0
        index += 1
        if index == professors.count {
            index = 0
        }
        let selection = professors[index]
        self.reservation.professor = selection
        self.updateProfessor()
    }
    
    @IBAction func onConfirmReservationTapped(_ sender: UIButton) {
        let alert = self.showSpinner(withMessage: "Reservando...")
        self.service.makeReservation(self.reservation) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                SCLAlertView().showSuccess("Reservado", subTitle: "La reservación se completó satisfactoriamente.")
                self?.container?.refresh()
                //self?.performSegue(withIdentifier: "backToStart", sender: sender)
                self?.performSegue(withIdentifier: "backToClasses", sender: sender)
            }
        }
    }
    
    class Section {
        var name: String
        var items: [String]
        var collapsed: Bool
        
        init(name: String, items: [String], collapsed: Bool = true) {
            self.name = name
            self.items = items
            self.collapsed = collapsed
        }
    }
}

extension ProfessorDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].collapsed ? 1 : sections[section].items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header1") as! HeaderCell
            cell.titleLabel.text = section.name
            
            if (section.collapsed){
                cell.titleLabel.textColor = self.collapsedColor
                cell.imgizq.image = UIImage(named:"fleizqoff")
                cell.imgder.image = UIImage(named:"flederoff")
            } else {
                cell.titleLabel.textColor = self.expandedColor
                cell.imgizq.image = UIImage(named:"flechaizq")
                cell.imgder.image = UIImage(named:"flechader")
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = section.items[indexPath.row - 1]
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard indexPath.row == 0 else { return nil}
        let section = sections[indexPath.section]
        section.collapsed = !section.collapsed
        tableView.reloadData()
        return nil
    }
}

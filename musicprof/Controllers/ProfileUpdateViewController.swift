//
//  ProfileUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 6/30/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ProfileUpdateViewController: UIViewController, RegistrationController, NestedController {
    var container: ContainerViewController?
    
    let checkedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    let normalColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
    
    let sections = [Section(id: "showAccount", title: "MI CUENTA"),
                    Section(id: "showInstruments", title: "MIS INSTRUMENTOS"),
                    Section(id: "showReservations", title: "MIS CLASES")]
    
    var client: Client!
    weak var tabController: CustomTabController?
    
    var selectedSection: Section? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var tableCollapseConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.client = self.service.user!
        self.tableCollapseConstraint.priority = .defaultLow
    }

    override func viewWillAppear(_ animated: Bool) {        
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? UINavigationController {
            controller.delegate = self
            self.tabController = controller.viewControllers.first as? CustomTabController
        }
    }
    
    private func updateLayout() {
        self.tableCollapseConstraint.priority = self.selectedSection == nil  ? .defaultLow : .defaultHigh
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func onUpdateAccount(_ sender: Any) {
        
    }
    
    struct Section {
        var id: String
        var title: String        
    }
}

extension ProfileUpdateViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? RegistrationController {
            controller.client = self.client
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === self.tabController {
            self.selectedSection = nil
            self.updateLayout()
        }
    }
}

extension ProfileUpdateViewController: UITableViewDelegate, UITableViewDataSource {
    var visibleSections: [Section] {
        //if let selection = self.selectedSection {
        //    return [selection]
        //}
        return self.sections
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedSection != nil && self.sections[indexPath.item].id != selectedSection!.id {
            return 0
        }
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visibleSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! HeaderCell
        let section = self.visibleSections[indexPath.item]
        cell.titleLabel.text = section.title
        
        if (self.selectedSection == nil){
            cell.titleLabel.textColor = normalColor
            cell.imgizq.image = UIImage(named:"fleizqoff")
            cell.imgder.image = UIImage(named:"flederoff")
        } else {
            cell.titleLabel.textColor = checkedColor
            cell.imgizq.image = UIImage(named:"flechaizq")
            cell.imgder.image = UIImage(named:"flechader")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard self.selectedSection == nil else { return nil }
        let section = self.visibleSections[indexPath.row]
        self.tabController?.navigate(to: section.id)
        self.selectedSection = section
        UIView.animate(withDuration: 0.5, animations: {
            tableView.layoutIfNeeded()
        }, completion: { _ in
            self.updateLayout()
        })
        return nil
    }
}

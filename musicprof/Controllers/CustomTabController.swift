//
//  CustomTabController.swift
//  musicprof
//
//  Created by John Doe on 6/30/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

typealias Section = UIViewController

@IBDesignable class CustomTabController: BaseNestedViewController {
    
    let checkedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    let normalColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
    
    open var sections: [UIViewController] {
        return []
    }
    
    var selectedSection: Section? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableCollapseConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableCollapseConstraint.priority = .defaultLow
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collapseSection()
        self.updateBackButton()
    }
    
    func updateLayout() {
        self.tableCollapseConstraint.priority = self.selectedSection == nil  ? .defaultLow : .defaultHigh
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func collapseSection() {
        self.selectedSection = nil
        self.updateLayout()
    }
    
    open func willShow(section controller: Section) {
    }
}

extension CustomTabController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === self {
            self.collapseSection()
            self.updateBackButton()
        }
    }
}

extension CustomTabController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedSection != nil && self.sections[indexPath.item] !== selectedSection {
            return 0
        }
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! HeaderCell
        let section = self.sections[indexPath.item]
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
        let section = self.sections[indexPath.row]
        //self.tabController?.navigate(to: section.id)
        self.navigationController?.pushViewController(section, animated: true)
        self.willShow(section: section)
        self.selectedSection = section
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.updateLayout()
        })
        return nil
    }
}

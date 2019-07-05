//
//  SubaccountListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/5/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class SubaccountListViewController: UIViewController, NestedController, RegistrationController {
    var client: Client!
    var container: ContainerViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    var elements = [Client]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.elements = self.client.subaccounts ?? []
    }
    
    @IBAction func onAddSubaccount(_ sender: Any) {
        self.performSegue(withIdentifier: "addSubaccount", sender: sender)
    }
    
    @IBAction func unwindToSubaccountList(_ segue: UIStoryboardSegue) {
        self.tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? InstrumentsRegistrationViewController else { return }
        switch segue.identifier {
        case "addSubaccount":
            controller.client = self.client
        case "editSubaccount":
            controller.client = self.client
            controller.editClient = self.elements[self.tableView.indexPathForSelectedRow!.item]
        default:
            break
        }
    }
}

extension SubaccountListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")!
        cell.textLabel?.text = self.elements[indexPath.item].name
        return cell
    }
}

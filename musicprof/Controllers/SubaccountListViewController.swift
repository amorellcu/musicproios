//
//  SubaccountListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/5/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class SubaccountListViewController: BaseNestedViewController, ClientRegistrationController, ProfileSection {
    weak var updater: ProfileUpdateViewController?
    var client: Client!
    
    @IBOutlet weak var tableView: UITableView!
    
    var elements = [Subaccount]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.elements = self.client.subaccounts ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
    }
    
    func refresh() {
        guard self.isViewLoaded else { return }
        self.elements = self.client.subaccounts ?? []
        self.tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        self.tableView.reloadData()
    }
    
    @IBAction func onAddSubaccount(_ sender: Any) {
        self.updater?.performSegue(withIdentifier: "addSubaccount", sender: sender)
    }
    
    @IBAction func unwindToSubaccountList(_ segue: UIStoryboardSegue) {
        self.client.subaccounts = self.service.currentClient?.subaccounts
        self.tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? InstrumentsRegistrationViewController else { return }
        switch segue.identifier {
        case "addSubaccount":
            controller.client = self.client
        case "editSubaccount":
            controller.client = self.client
            controller.subaccount = self.elements[self.tableView.indexPathForSelectedRow!.item]
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
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let subaccount = self.elements[indexPath.item]
        self.ask(question: "¿Está seguro de que quiere eliminar el estudiante?",
                 title: "Borrando", yesButton: "Sí", noButton: "No") { (shouldCancel) in
                    guard shouldCancel else { return }
                    let alert = self.showSpinner(withMessage: "Eliminando el estudiante...")
                    self.service.deleteSubaccount(subaccount) { [weak self] (result) in
                        alert.hideView()
                        self?.handleResult(result) {
                            self?.client.subaccounts?.remove(at: indexPath.item)
                            self?.elements = self?.client.subaccounts ?? []
                            self?.tableView.reloadData()
                        }
                    }
        }
    }
}

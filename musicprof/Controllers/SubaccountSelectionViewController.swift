//
//  SubaccountListViewController.swift
//  musicprof
//
//  Created by John Doe on 6/28/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class SubaccountSelectionViewController: BaseReservationViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var elements = [Student]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.elements = self.service.currentClient?.subaccounts ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selection = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selection, animated: false)
        }
    }
}

extension SubaccountSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elements.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.elements.count else {
            return tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")!
        cell.textLabel?.text = self.elements[indexPath.item].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.elements.count else {
            return self.performSegue(withIdentifier: "includeStudent", sender: tableView)
        }
        self.reservation.studentId = self.elements[indexPath.item].id
        self.reservation.studentType = .subaccount
        self.performSegue(withIdentifier: "selectInstrument", sender: tableView)
    }
}

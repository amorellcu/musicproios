//
//  SubaccountListViewController.swift
//  musicprof
//
//  Created by John Doe on 6/28/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class SubaccountListViewController: BaseReservationViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var elements = [Student]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.elements = self.service.user?.subaccounts ?? []
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.reservation.studentId = self.elements[indexPath.item].id
        self.reservation.studentType = .subaccount
        self.performSegue(withIdentifier: "selectInstrument", sender: tableView)
    }
}

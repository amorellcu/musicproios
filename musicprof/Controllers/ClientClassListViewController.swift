//
//  ClassListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/4/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ClientClassListViewController: ReservationListViewController {
    
    var reservations: [Reservation] = [] {
        didSet {
            self.classes = self.reservations.compactMap({$0.classes})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.timeStyle = .none
        self.dateFormatter.dateStyle = .long
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
        self.reservations = self.service.currentClient?.nextReservations ?? []
    }
    
    override func updateReservations() {
        guard let client = self.service.currentClient else { return }
        self.service.getNextClasses(of: client, type: .account) { [weak self] (result) in
            self?.handleResult(result) {
                self?.classes = $0
            }
        }
    }
    
    @IBAction func onMakeReservation(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        //self.performSegue(withIdentifier: "makeReservation", sender: sender)
    }
    
    @IBAction func unwindToClientClasses(_ segue: UIStoryboardSegue) {
        if let controller = segue.source as? ChatViewController, let selection = self.tableView.indexPathForSelectedRow?.item {
            if controller.reservation?.status == .cancelled {
                self.reservations.remove(at: selection)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.item < self.reservations.count && self.reservations[indexPath.item].status == .cancelled else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cancelledCell") as! ReservationCell
        self.configureCell(cell, forRowAt: indexPath)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let selection = self.tableView.indexPathForSelectedRow else { return }
        let theClass = reservations[selection.item]
        
        guard let controller = segue.destination as? ChatViewController else { return }
        controller.reservation = theClass
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
        guard editingStyle == .delete else {
            return
        }
        let reservation = self.reservations[indexPath.item]
        self.ask(question: "¿Está seguro de que quiere cancelar la reservación?",
                 title: "Cancelando", yesButton: "Sí", noButton: "No") { (shouldCancel) in
                    guard shouldCancel else { return }
                    let alert = self.showSpinner(withMessage: "Cancelando la reservación...")
                    self.service.cancelReservation(reservation, handler: { [weak self] (result) in
                        alert.hideView()
                        self?.handleResult(result) {
                            self?.reservations.remove(at: indexPath.item)
                        }
                    })
        }
    }
}

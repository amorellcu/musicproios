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
    var students: [Student]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.tintColor = .white
        self.tableView.refreshControl?.addTarget(self, action: #selector(updateReservations), for: .valueChanged)
        
        self.dateFormatter.timeStyle = .short
        self.dateFormatter.dateStyle = .medium
        
        self.sections = [ReservationListViewController.Section(name: nil, classes: nil)]
        self.tableView.tintColor = .white
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
        self.updateReservations()
    }
    
    override func updateReservations() {
        func cmpReservations(_ first: Reservation, _ second: Reservation) -> Bool {
            if first.classes == nil && second.classes == nil {
                return first.id < second.id
            }
            if let first = first.classes, let second = second.classes {
                return first.date < second.date
            }
            return second.classes != nil
        }
        
        guard let client = self.service.currentClient else { return }
        self.students = [client] + (client.subaccounts ?? [])
        self.sections = [Section(student: client, reservations: client.nextReservations)] + (client.subaccounts?.map {
            Section(student: $0, reservations: nil)
            } ?? [])
        self.tableView.reloadData()
        self.tableView.refreshControl?.beginRefreshing()
        self.service.getNextReservations(of: client) { [weak self] (result) in
            self?.tableView.refreshControl?.endRefreshing()
            self?.handleResult(result) { (values: [Reservation]) in
                guard let strongSelf = self, strongSelf.students?.first as? Client === client else { return }
                let reservations = values.sorted(by: cmpReservations)
                strongSelf.sections?[0] = Section(student: client, reservations: reservations)
                strongSelf.tableView.reloadSections(IndexSet([0]), with: .fade)
                self?.updateBadge()
            }
        }
        for (index, subaccount) in (client.subaccounts ?? []).enumerated() {
            self.service.getNextReservations(of: subaccount) { [weak self] (result) in
                self?.handleResult(result) { (values: [Reservation]) in
                    guard let strongSelf = self, let students = strongSelf.students, index + 1 < students.count && students[index + 1] as? Subaccount === subaccount else { return }
                    let reservations = values.sorted(by: cmpReservations)
                    strongSelf.sections?[index + 1] = Section(student: subaccount, reservations: reservations)
                    strongSelf.tableView.reloadSections(IndexSet([index + 1]), with: .fade)
                    self?.updateBadge()
                }
            }
        }
    }
    
    func createSection(forStudent student: Student, withReservations reservations: [Reservation]?) -> Section {
        let name = (student as? Subaccount)?.name
        let classes = reservations?.compactMap { (reservation: Reservation) -> Class? in
            guard var theClass = reservation.classes else { return nil }
            theClass.reservations = [reservation]
            return theClass
        }
        return Section(name: name, classes: classes)
    }
    
    func reservation(forRowAt indexPath: IndexPath) -> Reservation? {
        return self.getItem(forRowAt: indexPath)?.reservations?.first
    }
    
    @IBAction func onMakeReservation(_ sender: Any) {
        self.checkTermsAndConditions() { [weak self] in
            self?.performSegue(withIdentifier: "makeReservation", sender: sender)
        }
    }
    
    func removeReservation(at indexPath: IndexPath) {
        self.sections?[indexPath.section].classes?.remove(at: indexPath.row)
        self.tableView.reloadSections(IndexSet([indexPath.section]), with: .fade)
        self.container?.refresh()
    }
    
    @IBAction func unwindToClientClasses(_ segue: UIStoryboardSegue) {
        if let controller = segue.source as? ChatViewController, let selection = self.tableView.indexPathForSelectedRow {
            if controller.reservation?.status == .cancelled {
                self.removeReservation(at: selection)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard self.section(atIndex: section)?.classes?.count == 0 else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.section(atIndex: section)?.classes?.count == 0 else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let controller = segue.destination as? ReservationController {
            var reservation = ReservationRequest()
            var calendar = Calendar.current
            calendar.locale = Locale(identifier: "es-Es")
            reservation.calendar = calendar
            controller.reservation = reservation
        }
        
        guard let selection = self.tableView.indexPathForSelectedRow else { return }
        let theClass = self.reservation(forRowAt: selection)
        
        guard let controller = segue.destination as? ChatViewController else { return }
        controller.reservation = theClass
        controller.client = self.service.currentClient
        controller.professor = theClass?.classes?.professor
    }
    
    override func configureCell(_ cell: ReservationCell, forRowAt indexPath: IndexPath) {
        super.configureCell(cell, forRowAt: indexPath)
        guard let messageCountLabel = cell.messageCountLabel else { return }
        let count = self.getItem(forRowAt: indexPath)?.reservations?.first?.unreadMessages ?? 0
        messageCountLabel.isHidden = count == 0
        messageCountLabel.text = String(describing: count)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.reservation(forRowAt: indexPath)?.status == ReservationState.normal
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
        guard editingStyle == .delete, let reservation = self.reservation(forRowAt: indexPath) else {
            return
        }
        self.ask(question: "¿Está seguro de que quiere cancelar la reservación?",
                 title: "Cancelando", yesButton: "Sí", noButton: "No") { (shouldCancel) in
                    guard shouldCancel else { return }
                    let alert = self.showSpinner(withMessage: "Cancelando la reservación...")
                    self.service.cancelReservation(reservation, handler: { [weak self] (result) in
                        alert.hideView()
                        self?.handleResult(result) {
                            self?.removeReservation(at: indexPath)
                        }
                    })
        }
    }
    
    
}

fileprivate extension ReservationListViewController.Section {
    init(student: Student, reservations: [Reservation]?) {
        let name = (student as? Subaccount)?.name
        let classes = reservations?.compactMap { (reservation: Reservation) -> Class? in
            guard var theClass = reservation.classes else { return nil }
            theClass.reservations = [reservation]
            return theClass
        }
        self.init(name: name, classes: classes)
    }
}

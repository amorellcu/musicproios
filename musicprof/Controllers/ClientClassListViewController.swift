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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.tintColor = .white
        self.tableView.refreshControl?.addTarget(self, action: #selector(updateReservations), for: .valueChanged)
        
        self.dateFormatter.timeStyle = .short
        self.dateFormatter.dateStyle = .long
        
        self.sections = [ReservationListViewController.Section(name: nil, classes: nil)]
        self.tableView.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
        self.updateReservations()
    }
    
    override func updateReservations() {
        guard let client = self.service.currentClient else { return }
        self.sections = [StudentSection(student: client, reservations: client.nextReservations)] + (client.subaccounts?.map {
            StudentSection(student: $0, reservations: nil)
            } ?? [])
        self.service.getNextReservations(of: client) { [weak self] (result) in
            self?.tableView.refreshControl?.endRefreshing()
            self?.handleResult(result) { (values: [Reservation]) in
                let reservations = values.sorted(by: {
                    if $0.classes == nil && $1.classes == nil {
                        return $0.id < $1.id
                    }
                    if let first = $0.classes, let second = $1.classes {
                        return first.date < second.date
                    }
                    return $1.classes != nil
                })
                self?.sections?[0] = StudentSection(student: client, reservations: reservations)
            }
        }
        for (index, subaccount) in (client.subaccounts ?? []).enumerated() {
            self.service.getNextReservations(of: subaccount) { [weak self] (result) in
                self?.handleResult(result) { (values: [Reservation]) in
                    let reservations = values.sorted(by: {$0.classes?.date ?? Date() < $1.classes?.date ?? Date()})
                    self?.sections?[index + 1] = StudentSection(student: subaccount, reservations: reservations)
                }
            }
        }
    }
    
    func section(atIndex index: Int) -> StudentSection? {
        guard let sections = self.sections, index >= 0 && index < sections.count else { return nil }
        return sections[index] as? StudentSection
    }
    
    func reservation(forRowAt indexPath: IndexPath) -> Reservation? {
        guard let reservations = section(atIndex: indexPath.section)?.reservations, indexPath.row >= 0 && indexPath.row < reservations.count else {
            return nil
        }
        return reservations[indexPath.row]
    }
    
    @IBAction func onMakeReservation(_ sender: Any) {
        //self.tabBarController?.selectedIndex = 0
        self.performSegue(withIdentifier: "makeReservation", sender: sender)
    }
    
    func removeReservation(at indexPath: IndexPath) {
        guard let section = self.section(atIndex: indexPath.section), var reservations = section.reservations else { return }
        reservations.remove(at: indexPath.row)
        self.sections?[indexPath.section] = StudentSection(student: section.student, reservations: reservations)
    }
    
    @IBAction func unwindToClientClasses(_ segue: UIStoryboardSegue) {
        if let controller = segue.source as? ChatViewController, let selection = self.tableView.indexPathForSelectedRow {
            if controller.reservation?.status == .cancelled {
                self.removeReservation(at: selection)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard self.section(atIndex: section)?.reservations?.count == 0 else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.section(atIndex: section)?.reservations?.count == 0 else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = self.section(atIndex: indexPath.section) else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        guard let reservations = section.reservations else {
            return tableView.dequeueReusableCell(withIdentifier: "loadingCell")!
        }
        guard indexPath.row < reservations.count && reservations[indexPath.item].status == .cancelled else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cancelledCell") as! ReservationCell
        self.configureCell(cell, forRowAt: indexPath)
        return cell
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
    
    class StudentSection: ReservationListViewController.Section {
        let student: Student
        let reservations: [Reservation]?
        
        init(student: Student, reservations: [Reservation]?) {
            self.student = student
            self.reservations = reservations?.filter({$0.classes != nil})
            super.init(name: student is Client ? nil : student.name, classes: self.reservations?.compactMap({$0.classes}))
        }
    }
}

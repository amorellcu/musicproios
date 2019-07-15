//
//  ProfessorClassListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/14/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class ProfessorClassListViewController: ReservationListViewController {
    
    var selectedClass: Class?
    var clientCache: [Int:Client] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.classes = self.service.currentProfessor?.classes
        
        self.dateFormatter.timeStyle = .none
        self.dateFormatter.dateStyle = .long
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
        self.updateReservations()
    }
    
    override func updateReservations() {
        guard let professor = self.service.currentProfessor else { return }
        self.service.getNextClasses(of: professor) { [weak self] (result) in
            self?.handleResult(result) {
                self?.classes = $0
            }
        }
    }
    
    @IBAction func onMakeReservation(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        //self.performSegue(withIdentifier: "makeReservation", sender: sender)
    }
    
    @IBAction func unwindToProfessorClasses(_ segue: UIStoryboardSegue) {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.classes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedClass = self.selectedClass, let reservations = selectedClass.reservations, self.classes?[section].id == selectedClass.id else { return 1 }
        return reservations.count + 1
    }
    
    func configureCell(_ cell: UITableViewCell, forClient client: Client, forReservation reservation: Reservation) {
        let student: Student = client.subaccounts?.first(where: {$0.id == reservation.subaccountId}) ?? client
        cell.textLabel?.text = student.name
        guard let imageView = cell.imageView else { return }
        let placeholderAvatar = UIImage(named: "userdefault")?.af_imageAspectScaled(toFit: imageView.frame.size).af_imageRoundedIntoCircle()
        if let avatarUrl = client.avatarUrl {
            let filter = ScaledToSizeCircleFilter(size: imageView.frame.size)
            imageView.af_setImage(withURL: avatarUrl, placeholderImage: placeholderAvatar, filter: filter)
        } else {
            imageView.image = placeholderAvatar
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        guard let selectedClass = self.selectedClass, let reservations = selectedClass.reservations, self.classes?[section].id == selectedClass.id else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        guard indexPath.row > 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedCell") as! ReservationCell
            self.configureCell(cell, forRowAt: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientCell")!
        cell.imageView?.image = UIImage(named: "userdefault")
        cell.textLabel?.text = ""
        
        let reservation = reservations[indexPath.row - 1]
        self.service.getClient(withId: reservation.clientId) { [weak self] (result) in
            switch result {
            case .success(let client):
                self?.configureCell(cell, forClient: client, forReservation: reservation)
            default:
                break
            }
        }
        return cell
    }
    
    func updateReservations(ofClass selectedClass: Class, in section: Int) {
        guard let reservations = self.selectedClass?.reservations, let classId = self.selectedClass?.id else { return }
        for (i, reservation) in reservations.enumerated() {
            guard reservation.client == nil else { continue }
            if let client = self.clientCache[reservation.clientId] {
                if classId == self.selectedClass?.id {
                    self.selectedClass?.reservations?[i].client = client
                }
                self.classes?[section].reservations?[i].client = client
                continue
            }
            self.service.getClient(withId: reservation.clientId) { [weak self] (result) in
                switch result {
                case .success(let client):
                    if classId == self?.selectedClass?.id {
                        self?.selectedClass?.reservations?[i].client = client
                    }
                    self?.classes?[section].reservations?[i].client = client
                default:
                    break
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let classes = self.classes else { return nil }
        let section = indexPath.section
        if let _ = self.selectedClass, indexPath.row > 0 {
            return indexPath
        }
        var affectedSections = [section]
        if let selectedClass = self.selectedClass, let index = self.classes?.firstIndex(where: {$0.id == selectedClass.id}) {
            if index != section {
                affectedSections.append(index)
                self.selectedClass = classes[section]
                self.updateReservations(ofClass: classes[section], in: section)
            } else {
                self.selectedClass = nil
            }
        } else {
            self.selectedClass = classes[section]
            self.updateReservations(ofClass: classes[section], in: section)
        }
        tableView.reloadSections(IndexSet(affectedSections), with: .fade)
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let controller = segue.destination as? ClassController {
            var reservation = ClassRequest()
            var calendar = Calendar.current
            calendar.locale = Locale(identifier: "es-Es")
            reservation.calendar = calendar
            controller.reservation = reservation
        }
        
        guard let selection = self.tableView.indexPathForSelectedRow else { return }
        guard let theClass = self.classes?[selection.section], var reservation = theClass.reservations?[selection.row - 1] else { return }
        reservation.classes = theClass
        
        guard let controller = segue.destination as? ChatViewController else { return }
        controller.reservation = reservation
        controller.professor = self.service.currentProfessor
        controller.client = reservation.client
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
        guard editingStyle == .delete, let reservation = self.classes?[indexPath.section] else {
            return
        }
        self.ask(question: "¿Está seguro de que quiere cancelar la clase?",
                 title: "Cancelando", yesButton: "Sí", noButton: "No") { (shouldCancel) in
                    guard shouldCancel else { return }
                    let alert = self.showSpinner(withMessage: "Cancelando la reservación...")
                    self.service.cancelClass(reservation, handler: { [weak self] (result) in
                        alert.hideView()
                        self?.handleResult(result) {
                            self?.classes?.remove(at: indexPath.section)
                        }
                    })
        }
    }

}

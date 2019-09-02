//
//  ReservationListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class ReservationListViewController: BaseNestedViewController {
    
    let dateFormatter = DateFormatter()
    
    var sections: [Section]?
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dateFormatter.locale = Locale(identifier: "es-ES")
        self.dateFormatter.timeStyle = .short
        self.dateFormatter.dateStyle = .short
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateReservations()
    }
    
    @objc
    open func updateReservations() {
        guard let user = self.service.user else { return }
        self.service.getReservations(of: user) { [weak self] (result) in
            self?.handleResult(result) {
                self?.loadReservations($0)
            }
        }
    }
    
    open func loadReservations(_ reservations: [Reservation]) {
        let classes = reservations.compactMap({$0.classes})
        self.sections = [Section(name: nil, classes: classes)]
        self.tableView.reloadData()
    }
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? NestedController {
            controller.container = self.container
        }
    }
    
    func getItem(forRowAt indexPath: IndexPath) -> Class? {
        guard let sections = self.sections, indexPath.section < sections.count else { return nil }
        let section = sections[indexPath.section]
        guard let classes = section.classes, indexPath.row < classes.count else { return nil }
        return classes[indexPath.row]
    }
    
    open func configureCell(_ cell: ReservationCell, forRowAt indexPath: IndexPath) {
        guard let reservation = self.getItem(forRowAt: indexPath) else { return }
        if let iconURL = reservation.instrument?.iconUrl {
            var filter: ImageFilter = ScaledToSizeFilter(size: cell.instrumentImageView.frame.size)
            filter = TemplateFilter()
            cell.instrumentImageView.af_setImage(withURL: iconURL, filter: filter)
        } else {
            cell.instrumentImageView.image = UIImage(named: "no_instrument")
        }
        
        cell.dateLabel.text = self.dateFormatter.string(from: reservation.date)
        cell.professorLabel?.text = reservation.professor?.name
    }
    
    class Section {
        let name: String?
        let classes: [Class]?
        
        init(name: String?, classes: [Class]?) {
            self.name = name
            self.classes = classes
        }
    }
}

extension ReservationListViewController: UITableViewDelegate, UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections?[section].classes?.count ?? 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sections = self.sections, indexPath.section < sections.count && sections[indexPath.section].classes != nil else {
            return tableView.dequeueReusableCell(withIdentifier: "loadingCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "reservationCell") as! ReservationCell
        self.configureCell(cell, forRowAt: indexPath)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections?[section].name
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = self.sections?[section].name?.uppercased()
        label.backgroundColor = UIColor(red: 64/255, green: 65/255, blue: 66/255, alpha: 0.4)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "FilsonProRegular", size: 16)
        return label
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.sections?[section].name == nil ? 0 : 50
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return self.sections?[indexPath.section].classes == nil ? nil : indexPath
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Cancelar"
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {        
    }
}

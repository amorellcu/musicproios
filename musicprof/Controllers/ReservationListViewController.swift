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
    
    var classes: [Class]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
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
    
    open func updateReservations() {
        guard let user = self.service.user else { return }
        self.service.getReservations(of: user) { [weak self] (result) in
            self?.handleResult(result) {
                self?.loadReservations($0)
            }
        }
    }
    
    open func loadReservations(_ reservations: [Reservation]) {
        self.classes = reservations.compactMap({$0.classes})
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
    
    open func configureCell(_ cell: ReservationCell, forRowAt indexPath: IndexPath) {
        guard let reservation = self.classes?[indexPath.item] else { return }
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
}

extension ReservationListViewController: UITableViewDelegate, UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classes?.count ?? 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.classes != nil else {
            return tableView.dequeueReusableCell(withIdentifier: "loadingCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "reservationCell") as! ReservationCell
        self.configureCell(cell, forRowAt: indexPath)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return self.classes == nil ? nil : indexPath
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

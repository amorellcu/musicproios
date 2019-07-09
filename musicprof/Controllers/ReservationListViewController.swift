//
//  ReservationListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class ReservationListViewController: UIViewController, NestedController {
    var container: ContainerViewController?
    
    let dateFormatter = DateFormatter()
    
    var reservations: [Class]? {
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
        self.reservations = reservations.compactMap({$0.classes})
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
}

extension ReservationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reservations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reservation = self.reservations?[indexPath.item] else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "reservationCell") as! ReservationCell
        
        if let iconURL = reservation.instrument?.iconUrl {
            var filter: ImageFilter = ScaledToSizeFilter(size: cell.instrumentImageView.frame.size)
            filter = TemplateFilter()
            cell.instrumentImageView.af_setImage(withURL: iconURL, filter: filter)
        } else {
            cell.instrumentImageView.image = UIImage(named: "no_instrument")
        }
        
        cell.dateLabel.text = self.dateFormatter.string(from: reservation.date)
        cell.professorLabel?.text = reservation.professor?.name
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
    }
}

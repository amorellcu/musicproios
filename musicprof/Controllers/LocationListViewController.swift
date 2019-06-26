//
//  LocationListViewController.swift
//  musicprof
//
//  Created by John Doe on 6/25/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class LocationListViewController: BaseReservationViewController {
    
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var confirmationButton: UIButton!
    
    var selectedLocation: Location? {
        didSet {
            self.locationNameTextField.text = self.selectedLocation?.description
            self.confirmationButton.isEnabled = self.selectedLocation != nil
        }
    }
    var nearbyLocations: [Location]? = []
    
    override func loadView() {
        self.reservation.address = self.client?.address
        self.reservation.locationId = self.client?.locationId
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateSelectedLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    private func updateSelectedLocation() {
        guard let locationId = self.reservation.locationId else {
            return self.selectedLocation = nil
        }
        self.selectedLocation = nil
        self.service.getLocation(withId: locationId) { [weak self] (result) in
            self?.handleResult(result) {
                self?.selectedLocation = $0
            }
        }
    }
    
    private func updateNearbyLocations() {
        guard let address = reservation.address else {
            return self.nearbyLocations = []
        }
        self.nearbyLocations = nil
        self.service.getLocations(at: address) { [weak self] (result) in
            self?.handleResult(result) {
                self?.nearbyLocations = $0
            }
        }
    }
    
    @IBAction func unwindToLocations(_ segue: UIStoryboardSegue) {
        if let controller = segue.source as? MapViewController {
            self.reservation = controller.reservation
            self.selectedLocation = nil
            self.updateSelectedLocation()
            self.updateNearbyLocations()
        }
    }
    
    @IBAction func onConfirmLocationTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "selectDate", sender: sender)
    }
}

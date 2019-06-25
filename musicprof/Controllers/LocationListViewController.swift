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
    
    var locations: [Location]?
    
    var selectedLocation: Location? {
        didSet {
            self.locationNameTextField.text = self.selectedLocation?.name
            self.confirmationButton.isEnabled = self.selectedLocation != nil
        }
    }
    
    override func loadView() {
        self.reservation.address = self.client?.address
        self.reservation.locationId = self.client?.locationId
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateLocations()
    }
    
    private func updateLocations() {
        self.service.getLocations { [weak self] (result) in
            self?.handleResult(result) {
                self?.locations = $0
                self?.updateSelectedLocation()
            }
        }
    }
    
    private func updateSelectedLocation() {
        if let selectedId = self.reservation.locationId {
            self.selectedLocation = self.locations?.first(where: {$0.id == selectedId})
        } else {
            self.selectedLocation = nil
        }
    }
    
    @IBAction func unwindToLocations(_ segue: UIStoryboardSegue) {
        if let controller = segue.source as? MapViewController {
            self.reservation = controller.reservation
            self.selectedLocation = nil
            self.updateLocations()
        }
    }
    
    @IBAction func onConfirmLocationTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "selectDate", sender: sender)
    }
}

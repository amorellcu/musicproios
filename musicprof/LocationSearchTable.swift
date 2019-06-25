//
//  LocationSearchTable.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 21/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import MapKit
import SCLAlertView

protocol LocationSearchDelegate: class {
    func locationSearch(_ controller: LocationSearchTable, didSelectLocation placemark: MKPlacemark)
}

extension CLPlacemark {
    var address: String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (self.subThoroughfare != nil && self.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (self.subThoroughfare != nil || self.thoroughfare != nil) && (self.subAdministrativeArea != nil || self.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (self.subAdministrativeArea != nil && self.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            self.subThoroughfare ?? "",
            firstSpace,
            // street name
            self.thoroughfare ?? "",
            comma,
            // city
            self.locality ?? "",
            secondSpace,
            // state
            self.administrativeArea ?? ""
        )
        return addressLine
    }
}

class LocationSearchTable : UITableViewController {
    weak var delegate: LocationSearchDelegate?
    var locations: [MKMapItem] = []
    var mapView: MKMapView? = nil
    let alertView = SCLAlertView()
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.locations = response.mapItems
            self.tableView.reloadData()
        }
    }
    
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = locations[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.address
        return cell
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = locations[indexPath.row].placemark
        //self.address = parseAddress(selectedItem: selectedItem)
        delegate?.locationSearch(self, didSelectLocation: selectedItem)
    }
}

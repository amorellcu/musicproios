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
        let components: [String?] = [self.subThoroughfare, self.thoroughfare, self.subLocality, self.locality, self.subAdministrativeArea, self.administrativeArea, self.country]
        let addressLine = components.compactMap({$0}).reduce(into: [], { (array, value) in
            guard !array.contains(value) else { return }
            array.append(value)
        }).joined(separator: ", ")
        return addressLine
    }
}

class LocationSearchTable : UITableViewController {
    weak var delegate: LocationSearchDelegate?
    var locations: [MKMapItem] = []
    var mapView: MKMapView? = nil
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

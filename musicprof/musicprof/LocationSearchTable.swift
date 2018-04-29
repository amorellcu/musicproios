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

class LocationSearchTable : UITableViewController {
    var handleMapSearchDelegate:HandleMapSearch? = nil
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    let apimusicprof = ApiStudent()
    var token = ""
    var userid = 0
    let alertView = SCLAlertView()
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
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
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        //self.address = parseAddress(selectedItem: selectedItem)
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
        var localSearchRequest:MKLocalSearchRequest!
        var localSearch:MKLocalSearch!
        var localSearchResponse:MKLocalSearchResponse!
        var error:NSError!
        var pointAnnotation:MKPointAnnotation!
        var pinAnnotationView:MKPinAnnotationView!
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = selectedItem.title
        localSearch = MKLocalSearch(request: localSearchRequest)
        var annotation:MKAnnotation!
        
        if self.mapView?.annotations.count != 0{
            annotation = self.mapView?.annotations[0]
            self.mapView?.removeAnnotation(annotation)
        }
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = selectedItem.title
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self.mapView?.centerCoordinate = pointAnnotation.coordinate
            self.mapView?.addAnnotation(pinAnnotationView.annotation!)
        }
        //Update address to client
        let headers = [
            "Authorization": "Bearer \(self.token)",
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Requested-With": "XMLHttpRequest",
        ]
        let parameters = [
            "id": "\(self.userid)",
            "address": parseAddress(selectedItem: selectedItem)
        ]
        apimusicprof.setHeaders(aheader: headers)
        apimusicprof.setParams(aparams: parameters)
        apimusicprof.updateAddress() { json, error  in
            if(error != nil){
                self.alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor") // Error
            }
            else{
                let JSON = json! as NSDictionary
                if(String(describing: JSON["result"]!) == "Error"){
                    self.alertView.showError("Error Ubicación", subTitle: String(describing: JSON["message"]!)) // Error
                }
            }
        }
        
    }
}

//
//  MapViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 20/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SCLAlertView

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var mapview: MKMapView!
    let locationManager = CLLocationManager()
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var selectedPin:MKPlacemark? = nil
    var namePerfil: String!
    var photoPerfil: UIImage!
    var facebookid: String = ""
    var phone: String = ""
    let apimusicprof = ApiStudent.sharedInstance
    var instrumentsid: [Int] = []
    var user:NSDictionary = [:]
    let alertView = SCLAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController.searchResultsUpdater = locationSearchTable
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Buscar una ubicación"
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        let data = self.user["data"] as? [String: Any]
        let client = data!["client"] as? [String: Any]
        locationSearchTable.mapView = mapview
        locationSearchTable.token = data!["token"]! as! String
        locationSearchTable.userid = client!["users_id"]! as! Int
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapview.setRegion(region, animated: true)
        mapview.showsUserLocation = true
    }
    
    
    @IBAction func fixUbication(_ sender: Any) {
        let data = self.user["data"] as? [String: Any]
        let client = data!["client"] as? [String: Any]
        let headers = [
            "Authorization": "Bearer \(data!["token"]! as! String)",
            "X-Requested-With": "XMLHttpRequest"
        ]
        let parameters = [
            "id": client!["users_id"]! as! Int
        ]
        apimusicprof.setHeaders(aheader: headers)
        apimusicprof.setParams(aparams: parameters)
        apimusicprof.getClient() { json, error  in
            if(error != nil){
                self.alertView.showError("Error Conexion", subTitle: "No hemos podido conectarnos con el servidor") // Error
            }
            else{
                let JSON = json! as NSDictionary
                if(String(describing: JSON["result"]!) == "Error"){
                    self.alertView.showError("Error Obteniendo usuario", subTitle: String(describing: JSON["message"]!)) // Error
                } else if(String(describing: JSON["result"]!) == "OK"){
                    print(JSON)
                    let data = JSON["data"] as? [String: Any]
                    let client = data!["client"] as? [String: Any]
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView1 = SCLAlertView(appearance: appearance)
                    alertView1.addButton("OK") {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                    alertView1.showSuccess("Ubicación Actualizada", subTitle: "La ubicación ha sido actualizada a \(String(describing: client!["address"]!))")
                    

                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapview.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapview.removeAnnotations(mapview.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapview.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapview.setRegion(region, animated: true)
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0,y :0), size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: "getDirections", for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}

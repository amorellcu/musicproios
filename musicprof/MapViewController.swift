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

class MapViewController: BaseReservationViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var fixAddressButton: UIButton!
    @IBOutlet weak var tapGestureRecognizer: MKMapView!
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var searchController: UISearchController!
    
    var selectedLocation: MKPlacemark? = nil {
        didSet {
            self.fixAddressButton.isEnabled = self.userLocation != nil || self.selectedLocation != nil
        }
    }
    
    var userLocation: CLPlacemark? = nil {
        didSet {
            self.fixAddressButton.isEnabled = self.userLocation != nil || self.selectedLocation != nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = self.mapView
        locationSearchTable.delegate = self
        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController.searchResultsUpdater = locationSearchTable
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Buscar una ubicación"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.container?.navigationItem.titleView = searchController.searchBar
        self.container?.setDisplayMode(.collapsed, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.container?.navigationItem.titleView = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onFixAddressTapped(_ sender: Any) {
        guard let location = self.selectedLocation ?? self.userLocation else {
            return
        }
        let address = location.address
        self.service.updateAddress(address) {[weak self] (result) in
            self?.handleResult(result)
        }
    }
    
    @IBAction func onMapTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        let locationInView = sender.location(in: mapView)
        let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: tappedCoordinate.latitude, longitude: tappedCoordinate.longitude)
        self.geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                self.notify(error: error)
            } else if let placemark = placemarks?.first {
                self.selectedLocation = MKPlacemark(placemark: placemark)
                self.annotateLocation(self.selectedLocation!)
            }
        }
    }
    
    @objc func onNavigateToDestination() {
        if let selectedPin = selectedLocation {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func moveToLocation(_ location: CLLocation) {
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func annotateLocation(_ placemark: MKPlacemark) {
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        //let annotation = MKPointAnnotation()
        //annotation.coordinate = placemark.coordinate
        //annotation.title = placemark.name
        //if let city = placemark.locality,
        //    let state = placemark.administrativeArea {
        //    annotation.subtitle = "\(city) \(state)"
        //}
        //mapView.addAnnotation(annotation)
        mapView.addAnnotation(placemark)
    }
    
    @IBAction func onGoToLocationTapped(_ sender: Any) {
        guard let location = self.locationManager.location else { return }
        self.moveToLocation(location)
    }
}

extension MapViewController: UISearchBarDelegate {
    
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        if self.userLocation == nil {
            self.geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    self.notify(error: error)
                } else if let placemark = placemarks?.first {
                    self.userLocation = placemark
                }
            }
        }
        
        if selectedLocation == nil  {
            self.moveToLocation(location)
        }
        
        mapView.showsUserLocation = true
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension MapViewController: LocationSearchDelegate {
    func locationSearch(_ controller: LocationSearchTable, didSelectLocation placemark: MKPlacemark) {
        self.searchController.isActive = false
        
        self.selectedLocation = placemark
        self.annotateLocation(placemark)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView?.annotation = annotation
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0,y :0), size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(onNavigateToDestination), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}

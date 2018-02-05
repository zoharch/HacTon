//
//  DoneDonatingController.swift
//  OurHackathonDonation
//
//  Created by hackeru on 01/02/2018.
//  Copyright © 2018 Bar Arbiv. All rights reserved.
//
// used tutorial: https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class LocationSearchViewController: UIViewController {
    private var address:String!
    public func setAdress(_ address:String) {
        self.address = address
    }
    var locationManager:CLLocationManager!
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    
    @IBAction func ok() {
        // todo passback the address
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    private func isLocationPermissionGranted() -> Bool
    {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        return [.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager() //initialize location manager
        locationManager.requestWhenInUseAuthorization()// prompt user current location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.delegate = self //assign instance self as delegate property
        
        //map layer type
        mapView.mapType = .standard
        
        // uisearchcontroller:
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
    
        //searchbar:
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "הזן כתובת"
        navigationItem.titleView = resultSearchController?.searchBar
        
        // UISearchController appearance
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self        
    }
    
}
extension LocationSearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: \(location)")
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        address = "לא מצליח לאתר מיקום, רשום ידנית בבקשה"
        print("error: \(error)")
    }
    
}
extension LocationSearchViewController: MKMapViewDelegate {
    //when user's location changed (walking, driving, etc..)
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //reset region to each location changed
        let newPlace = userLocation.coordinate
        let location = CLLocation(latitude: newPlace.latitude, longitude: newPlace.longitude)
        //print(location)
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: nil) { (placemarks, error) in
            print(location)
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
            }
            
            if let count = placemarks?.count {
                if count > 0 {
                    let pm = placemarks![0]
                    if let name = pm.name {
                        var result = name
                        /*
                         if let street = pm.thoroughfare {
                         result += ", \(street)"
                         }
                         */
                        if let city = pm.locality {
                            result += ", \(city)"
                        }
                        /*
                         if let country = pm.country {
                         result += ", \(country)"
                         }*/
                        print("locality:")
                        print(result)
                        
                    }
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            }
        }
        
    }
}

extension LocationSearchViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}


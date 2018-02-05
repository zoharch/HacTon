//
//  LocationSearchViewController.swift
//  OurHackathonDonation
//
//  Created by user134028 on 2/4/18.
//  Copyright © 2018 Bar Arbiv. All rights reserved.
//

import UIKit
import MapKit

class DoneDonatingController: UIViewController {
   internal var locationManager: CLLocationManager!
    internal var selectedPin: MKPlacemark?
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var addressBTN: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func done(_ sender: Any) {
        let userName = nameTF.text!
        let alert = UIAlertController(title: "\(userName) תודה", message: "שליח יתקשר איתך בהקדם!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(ok) in
            self.navigationController?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func changeAddress() {
        let next = storyboard!.instantiateViewController(withIdentifier: "mapSearch") as! LocationSearchViewController
        next.setAdress(addressBTN.currentTitle!)
        present(next, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager() //initialize location manager
        locationManager.requestWhenInUseAuthorization()// prompt user current location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self //assign instance self as delegate property
        
        //map layer type
        mapView.mapType = .standard
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension DoneDonatingController: CLLocationManagerDelegate {
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
        self.addressBTN.setTitle("לחץ לעדכון כתובתך, לא הצלחנו לאתר בצורה אוטומטית",for: UIControlState.normal) 
        print("error: \(error)")
    }
    
}
extension DoneDonatingController: MKMapViewDelegate {
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
                        let msg = "לחץ לשינוי הכתובת - " + "\n" + result
                        self.addressBTN.setTitle(msg, for: UIControlState.normal)
                    }
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            }
        }
        
    }
}

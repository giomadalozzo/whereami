//
//  ViewController.swift
//  WhereAmI
//
//  Created by Giovanni Madalozzo on 01/12/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var coreLocationManager = CLLocationManager()
    var locationManager: LocationManager!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var jokingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBAction func updateButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreLocationManager.delegate = self
        locationManager = LocationManager.shared
        
        if coreLocationManager.authorizationStatus == CLAuthorizationStatus.notDetermined && coreLocationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            coreLocationManager.requestWhenInUseAuthorization()
        }else{
            getLocation()
        }
    }
    
    func getLocation(){
        locationManager.getLocation { location, error in
            self.displayLocation(location: CLLocation(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude))
        }
    }
    
    func displayLocation(location: CLLocation){
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        let locationPinCoord = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationPinCoord
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.notDetermined || status != CLAuthorizationStatus.denied || status != CLAuthorizationStatus.restricted {
            getLocation()
        }
    }


}


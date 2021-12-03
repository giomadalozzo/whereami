//
//  ViewController.swift
//  WhereAmI
//
//  Created by Giovanni Madalozzo on 01/12/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var coreLocationManager = CLLocationManager()
    var locationManager: LocationManager!
    
    var annotationList: [MKAnnotation] = []
    var count: Int = 0

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var jokingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBAction func updateButton(_ sender: Any) {
        mapView.removeAnnotations(annotationList)
        getLocation()
        self.count = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreLocationManager.delegate = self
        mapView.delegate = self
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
        
        annotationList = []
        annotationList.append(annotation)
        mapView.addAnnotation(annotation)
        
        for _ in 0...4{
            let annotationAux = MKPointAnnotation()
            annotationAux.coordinate.longitude = annotation.coordinate.longitude + Double.random(in: 0.001...0.005)
            annotationAux.coordinate.latitude = annotation.coordinate.latitude + Double.random(in: 0.001...0.005)
            mapView.addAnnotation(annotationAux)
            annotationList.append(annotationAux)
        }
        mapView.showAnnotations(annotationList, animated: true)
        
        locationManager.getReverseGeoCodedLocation(location: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)) { location, placemark, error in
            if self.count == 0 {
                self.locationLabel.text = "Hmmmm, your location is the red mark 🤠 Click on it to get more info"
                self.count += 1
            }else{
                self.locationLabel.text = self.addressFormatter(placemark: placemark!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.notDetermined || status != CLAuthorizationStatus.denied || status != CLAuthorizationStatus.restricted {
            getLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        locationManager.getReverseGeoCodedLocation(location: CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)) { location, placemark, error in
            
            self.locationLabel.text = self.addressFormatter(placemark: placemark!)
            if self.locationLabel.text == "" {
                self.locationLabel.text = "Sorry, but Idk where you at"
            }
        }
    }
    
    func addressFormatter(placemark: CLPlacemark) -> String {
        guard let thoroughfare = placemark.thoroughfare else {
            return ""
        }
        
        guard let subThoroughfare = placemark.subThoroughfare else {
            return ""
        }
        
        guard let subLocality = placemark.subLocality else {
            return ""
        }
        
        guard let locality = placemark.locality else {
            return ""
        }
        
        guard let administrativeArea = placemark.administrativeArea else {
            return ""
        }
        
        guard let country = placemark.country else {
            return ""
        }
        return thoroughfare + ", " + subThoroughfare + ", " + subLocality + ", " + locality + " - " + administrativeArea + ", " + country
    }


}


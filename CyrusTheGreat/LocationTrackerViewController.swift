//
//  LocationTrackerViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 4/20/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationTrackerViewController: UIViewController {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var currMapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Find current Location of user
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - CLLocationManagerDelegate
//1
extension LocationTrackerViewController: CLLocationManagerDelegate {
    //2
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 3
        if status == .AuthorizedWhenInUse {
            // 4
            locationManager.startUpdatingLocation()
            // 5
            currMapView.myLocationEnabled = true
            currMapView.settings.myLocationButton = true
        }
    }
    
    // 6
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            let home = CLLocationCoordinate2DMake(39.3435, -75.5846)
            
            // 7
            currMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
            let markPosition = GMSMarker(position: location.coordinate)
            markPosition.title = "My Position"
            markPosition.map = currMapView
            
            let otherPosition = GMSMarker(position: home)
            otherPosition.title = "Position Home"
            otherPosition.map = currMapView
//            currMapView.camera = GMSCameraPosition(target: home, zoom: 5, bearing: 0, viewingAngle: 0)
            
            //8
            locationManager.stopUpdatingLocation()
        }
    }
}


// MARK: - GoogleMapDelegate

extension LocationTrackerViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
//        reverseGeocodeCoordinate(position.target)
    }
    
    
    
//    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
//        adressLabel.lock()
//    }
    
    
    
}


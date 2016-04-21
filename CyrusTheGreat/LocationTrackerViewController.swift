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
    let mapTasks = MapTasks()
    var routePolyline: GMSPolyline!
    
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!

    @IBOutlet weak var currMapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Find current Location of user
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
//        currRoute()
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
    
    
    func currRoute(origin:CLLocation) {
        origin.coordinate.longitude
        self.mapTasks.getDirections("\(origin.coordinate.latitude),\(origin.coordinate.longitude)", destination: "3300 North Charles Street,Baltimore, MD 21218", waypoints: nil, travelMode: TravelModes.driving, completionHandler: { (status, success) -> Void in
            if success {
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
//                self.displayRouteInfo()
            }
            else {
                print(status)
            }
        })
    }
    
    
    func configureMapAndMarkersForRoute() {
        currMapView.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 9.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.currMapView
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.mapTasks.originAddress
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.currMapView
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        destinationMarker.title = self.mapTasks.destinationAddress
        
        
//        if waypointsArray.count > 0 {
//            for waypoint in waypointsArray {
//                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
//                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
//                
//                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
//                marker.map = viewMap
//                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
//                
//                markersArray.append(marker)
//            }
//        }
    }
    
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = currMapView
    }
    
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil

    }

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
    
//    // 6
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("Location Manager calleld")
//        if let location = locations.last {
//            
////            let home = CLLocationCoordinate2DMake(39.3435, -75.5846)
//            
//            // 7
//            currMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
//            let markPosition = GMSMarker(position: location.coordinate)
//            markPosition.title = "My Position"
//            markPosition.map = currMapView
//            
////            currRoute(location)
//            
////            let otherPosition = GMSMarker(position: home)
////            otherPosition.title = "Position Home"
////            otherPosition.map = currMapView
////            currMapView.camera = GMSCameraPosition(target: home, zoom: 5, bearing: 0, viewingAngle: 0)
//            
//            //8
//            locationManager.stopUpdatingLocation()
//        }
//    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
       print("old coordinate \(oldLocation.coordinate)")
        print("new coordinate \(newLocation.coordinate)")
        
        print ("\((oldLocation.coordinate.longitude != newLocation.coordinate.longitude) || (oldLocation.coordinate.latitude != newLocation.coordinate.latitude))")
        
        if (oldLocation.coordinate.longitude != newLocation.coordinate.longitude) || (oldLocation.coordinate.latitude != newLocation.coordinate.latitude) {
            
            currMapView.camera = GMSCameraPosition(target: newLocation.coordinate, zoom: 10, bearing: 0, viewingAngle: 0)
            let markPosition = GMSMarker(position: newLocation.coordinate)
            markPosition.title = "My Position"
            markPosition.map = currMapView
            currRoute(newLocation)
            
            print("Location Updated")
            
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


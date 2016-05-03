//
//  LocationTrackerViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 4/20/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class LocationTrackerViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let locationManager = CLLocationManager()
    let mapTasks = MapTasks()
    var allMarkers = [GMSMarker]()
    var routePolyline: GMSPolyline!
    
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var otherUserDestinationMarker: GMSMarker!
    
    var locationFireBase: Firebase!
    var myLocationFireBase: Firebase!
    
    var locationCloseness: Firebase!

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currMapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationFireBase = Firebase(url:"https://cyrusthegreat.firebaseio.com/location")
        myLocationFireBase = locationFireBase.childByAppendingPath("\(UIDevice.currentDevice().name)")
        locationCloseness = locationFireBase.childByAppendingPath("arrived")
//        myLocationFireBase.setValue("empty")
//        locationFireBase.setValue("empty")
        
        locationFireBase.observeEventType(.Value, withBlock: {
            snapshot in
            
            
            for child in snapshot.children {
                
                print ("current child info is \(child.key)")
                
                if child.key != UIDevice.currentDevice().name {
                    
                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    
                    if let coordinateDistanceInString = childSnapshot.value as? String {
                        
                        let informationArray = coordinateDistanceInString.componentsSeparatedByString("_duration_")
                        
                        let coordinateInString = informationArray[0]
                        let timeToDestinationOfOtherUser = informationArray[1]
                        
                        
                        let coordinateArray = coordinateInString.componentsSeparatedByString(",")
                        let latString = coordinateArray[1]
                        let longString = coordinateArray[0]
                        
                        
                        let lat = (latString as NSString).doubleValue
                        let long = (longString as NSString).doubleValue
                        
                        let latDegrees: CLLocationDegrees = lat
                        let longDegrees: CLLocationDegrees = long
                        
                        let coordinate = CLLocationCoordinate2DMake(latDegrees , longDegrees)
                        
                        
                        if (self.otherUserDestinationMarker != nil) {
                            self.otherUserDestinationMarker.map = nil
                            self.clearOtherUser()
                            
                        }
                        self.otherUserDestinationMarker = GMSMarker(position: coordinate)
                        
                        self.otherUserDestinationMarker.map = self.currMapView
                        self.otherUserDestinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blackColor())
                        self.otherUserDestinationMarker.title = "Other user address"
                        
                        print("Time of other user \(timeToDestinationOfOtherUser) away from destination")
                        self.durationLabel.text = "Other user is \(timeToDestinationOfOtherUser) away from destination"
                        print("appending other user info to marker array")
                        
                        self.allMarkers.append(self.otherUserDestinationMarker)
                        self.drawBounds()
                        
                       
                        
                    } else {
                        print("No Value for present")
                    }
                    
                }
            }
            
                    
            
 
            
                
                
        })
        
        // Find current Location of user
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
       
        
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
        self.mapTasks.getDirections("\(origin.coordinate.latitude),\(origin.coordinate.longitude)", destination: "3300 North Charles Street,Baltimore, MD 21218", waypoints: nil, travelMode: TravelModes.walking, completionHandler: { (status, success) -> Void in
            if success {
                
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
                self.drawBounds()
                self.myLocationFireBase.setValue("\(origin.coordinate.longitude),\(origin.coordinate.latitude)_duration_\(self.mapTasks.totalDuration)")
//                self.displayRouteInfo()
                print("Duration of from destination \(self.mapTasks.totalDuration)")
//                self.mapTasks.totalDistance
                print("Distance in km \(self.mapTasks.totalDistanceInMeters)")
                if (self.mapTasks.totalDistanceInMeters < 5) {
//                    self.locationCloseness.updateChildValues([self.appDelegate.userIdentifier : "yes"])
                    
                }
            }
            else {
                print(status)
            }
        })
    }
    
    func checkMap() -> Bool! {
        return destinationMarker != nil
    }
    
    func drawBounds() {
        
        
        let path = GMSMutablePath()
        
        print("Count of markers \(allMarkers.count)")

        for marker in allMarkers {
            path.addCoordinate(marker.position)
        }
        
        let bounds = GMSCoordinateBounds(path: path)
        self.currMapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 30.0))
    }
    
    func configureMapAndMarkersForRoute() {
//        currMapView.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 10.0)
        
//        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
//        originMarker.map = self.currMapView
//        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
//        originMarker.title = self.mapTasks.originAddress
        
        
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        
        print ("Destination coordinates are: \(self.mapTasks.destinationCoordinate)")
        
        destinationMarker.map = self.currMapView
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        destinationMarker.title = self.mapTasks.destinationAddress
        
//        let bounds = GMSCoordinateBounds(coordinate: self.mapTasks.originCoordinate, coordinate: self.mapTasks.destinationCoordinate)
//        let camera = currMapView.cameraForBounds(bounds, insets: UIEdgeInsetsZero)
//        currMapView.camera = camera!
        
        self.allMarkers.append(destinationMarker)
        
//         self.currMapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 30.0))
        
//        drawBounds(self.mapTasks.destinationCoordinate)
        
    }
    
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = currMapView
    }
    
    func clearOtherUser() {
        
        if  (otherUserDestinationMarker != nil) {
            self.allMarkers.removeObject(otherUserDestinationMarker)
//            otherUserDestinationMarker.map = nil
//            otherUserDestinationMarker = nil
        }
        
    }
    
    func clearRoute() {
//         allMarkers = [GMSMarker]()
        
        if (self.originMarker != nil) {
            
            print("Removing origin Marker")
            
            self.allMarkers.removeObject(self.originMarker)
            
            print("After removing origin allMarkers is \(allMarkers.count)")
            originMarker.map = nil
            originMarker = nil
        }
        
        
        
        if (destinationMarker != nil) {
            
            print("Removing destination Marker")
            self.allMarkers.removeObject(destinationMarker)
            
            print("After removing destination allMarkers is \(allMarkers.count)")
            
            destinationMarker.map = nil
            destinationMarker = nil
        }
        if (routePolyline != nil) {
            routePolyline.map = nil
            routePolyline = nil
            
        }
        
        

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
            
            
            let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(48.857165, longitude: 2.354613, zoom: 8.0)
            currMapView.camera = camera
            
//            currMapView.
        
        }
    }
    
    // 6
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location Manager calleld")
        if let location = locations.first {
            
            
            self.clearRoute()
            
            
            print("new location coordinate \(location.coordinate)")
            
            
            print("number in allMarkers: \(allMarkers.count)")
            
            originMarker = GMSMarker(position: location.coordinate)
            allMarkers.append(originMarker)
            currRoute(location)
            

            
            
            
            
            
            //8
//            locationManager.stopUpdatingLocation()
        }
    }
    
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        for location in locations as! [CLLocation] {
//            if location.horizontalAccuracy < 20 {
//                //update distance
//                if self.locations.count > 0 {
//                    distance += location.distanceFromLocation(self.locations.last)
//                }
//                
//                //save location
//                self.locations.append(location)
//            }
//        }
//    }
    
    
//    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
//        
////        if (stringLongSub) > 0 || (stringLatSub) > 0 {
//        
////            print("Longitude subtraction \(oldLocation.coordinate.longitude - newLocation.coordinate.longitude)")
////            print("Latitude subtraction \(oldLocation.coordinate.latitude - newLocation.coordinate.latitude)")
//        
////            currMapView.camera = GMSCameraPosition(target: newLocation.coordinate, zoom: 5, bearing: 0, viewingAngle: 0)
////        
////         GMSCameraUpdate.setTarget(newLocation.coordinate, zoom: 10)
//        // Set Location so other user can know
////            print()
////            myLocationFireBase.setValue("\(newLocation.coordinate.longitude),\(newLocation.coordinate.latitude)_duration_\(mapTasks.totalDuration)")
//            
//            originMarker = GMSMarker(position: newLocation.coordinate)
//            
//            
//            allMarkers.append(originMarker)
////            let markPosition = GMSMarker(position: newLocation.coordinate)
////            markPosition.title = "My Position"
////            markPosition.map = currMapView
//            currRoute(newLocation)
//            
////             drawBounds(newLocation.coordinate)
//            
//            print("Location Updated")
//            
////        }
//
//        
//    }
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

// Array Extension
extension Array where Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}


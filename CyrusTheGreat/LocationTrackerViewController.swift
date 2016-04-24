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

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currMapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationFireBase = Firebase(url:"https://cyrusthegreat.firebaseio.com/location")
        myLocationFireBase = locationFireBase.childByAppendingPath("\(UIDevice.currentDevice().name)")
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
    
    override func viewWillAppear(animated: Bool) {
        
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
                self.drawBounds()
                self.myLocationFireBase.setValue("\(origin.coordinate.longitude),\(origin.coordinate.latitude)_duration_\(self.mapTasks.totalDuration)")
//                self.displayRouteInfo()
                print("Duration of from destination \(self.mapTasks.totalDuration)")
            }
            else {
                print(status)
            }
        })
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
        currMapView.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 10.0)
        
//        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
//        originMarker.map = self.currMapView
//        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
//        originMarker.title = self.mapTasks.originAddress
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        
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
        
        let longSub = oldLocation.coordinate.longitude - newLocation.coordinate.longitude
        let latSub = oldLocation.coordinate.latitude - newLocation.coordinate.latitude
        let stringLongSub = Double(String(format:"%.2f", longSub))
        let stringLatSub = Double(String(format:"%.2f", latSub))
        
        print(stringLongSub)
        print(stringLatSub)
        
        if (stringLongSub) > 0 || (stringLatSub) > 0 {
            
            print("Longitude subtraction \(oldLocation.coordinate.longitude - newLocation.coordinate.longitude)")
            print("Latitude subtraction \(oldLocation.coordinate.latitude - newLocation.coordinate.latitude)")
            
            currMapView.camera = GMSCameraPosition(target: newLocation.coordinate, zoom: 5, bearing: 0, viewingAngle: 0)
            // Set Location so other user can know
//            print()
//            myLocationFireBase.setValue("\(newLocation.coordinate.longitude),\(newLocation.coordinate.latitude)_duration_\(mapTasks.totalDuration)")
            
            originMarker = GMSMarker(position: newLocation.coordinate)
            
            
            allMarkers.append(originMarker)
//            let markPosition = GMSMarker(position: newLocation.coordinate)
//            markPosition.title = "My Position"
//            markPosition.map = currMapView
            currRoute(newLocation)
            
//             drawBounds(newLocation.coordinate)
            
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

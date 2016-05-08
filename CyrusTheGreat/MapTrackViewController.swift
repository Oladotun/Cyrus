//
//  MapTrackViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/3/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class Annotation:MKPointAnnotation
{
    var color: UIColor?
}

protocol MapTrackerDelegate {
    
    func arrived()
}

class MapTrackViewController: UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
   
    var addressString:String!
    var destinationPlacemark:MKPlacemark!
    var destinationLocation:CLLocation!
    var myLocation: CLLocation!
    var otherUserLocation: CLLocation!
    
    var locationFireBase: Firebase!
    var locationExactBase: Firebase!
    var locationArrived: Firebase!
    
    var destinationAnnotation:Annotation!
    var otherUserAnnotation:Annotation!
    var sourceAnnotation: Annotation!
    
    // 
    var mapProtocol:MapTrackerDelegate?
    var myArrival:Bool!
    var userArrival:Bool!
    
    var myETA = NSTimeInterval()
    @IBOutlet weak var labelETA: UILabel!
    @IBOutlet weak var myETALabel: UILabel!
    @IBOutlet weak var theMap: MKMapView!
    
    var protocolCalled = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.locationManager!.delegate = self
        appDelegate.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        appDelegate.locationManager.distanceFilter = 20 // Updates after moves 20 meters
        theMap.delegate = self
        theMap.mapType = MKMapType.Standard
        
        locationFireBase = Firebase(url:"https://cyrusthegreat.firebaseio.com/location")
        locationExactBase = locationFireBase.childByAppendingPath(appDelegate.otherUserIdentifieir)
        locationArrived = locationFireBase.childByAppendingPath("arrived")
        destinationPlacemark = MKPlacemark(coordinate: destinationLocation.coordinate, addressDictionary: nil)
        
        myArrival = false
        userArrival = false
        
        self.fireBaseBusiness()
        theMap.showsUserLocation = true
        appDelegate.locationManager!.startUpdatingLocation()
        // Do any additional setup after loading the view.
        
        destinationAnnotation = initializeAnnotations("Destination", color: UIColor.greenColor())
        sourceAnnotation = initializeAnnotations("Current Location", color: UIColor.blueColor())
        otherUserAnnotation = initializeAnnotations("Other User Location", color: UIColor.purpleColor())
        destinationAnnotation.coordinate = destinationLocation.coordinate
        
        

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeAnnotations(title:String,color:UIColor)-> Annotation {
        
        let annotation = Annotation()
        annotation.title = title
        annotation.color = color
        theMap.addAnnotation(annotation)
        return annotation
        
        
    }
    
    func checkIfBothUserArrived() {
        if (myArrival == true && userArrival == true && protocolCalled == 0) {
            protocolCalled = protocolCalled + 1
            mapProtocol?.arrived()
        }
        
    }
    
    func labelFromETA(ETA:NSTimeInterval,title:String) {
        
        if (title == "first") {
            
            let userInfo = [self.appDelegate.userIdentifier: ETA]
            locationArrived.updateChildValues(userInfo)
            myETA = ETA
            let myETAString = myETA.stringFromTimeInterval(myETA)
            myETALabel.text = "I am \(myETAString) from destination"
            myArrival = calculateArrival(ETA)
            
            if(myArrival == true) {
                print("I will stop updating location")
                appDelegate.locationManager.stopUpdatingLocation()
            }
            checkIfBothUserArrived()
        
            
        }
        
    }
    
    func calculateArrival(ETA:NSTimeInterval) -> Bool {
        
        let interval = Int(ETA)
        //        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        if (hours < 1 && minutes < 2) {
            return true
        }
        
        return false
        
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

extension MapTrackViewController {
    
    func fireBaseBusiness() {
        
        locationArrived.observeEventType(.Value, withBlock: {
            snapshot in
        
                for youngChild in snapshot.children {
                    
                    if youngChild.key != UIDevice.currentDevice().name {
                        
                        let youngChildSnapshot = snapshot.childSnapshotForPath(youngChild.key)
                        
                        if let youngChildETA = youngChildSnapshot.value as? NSTimeInterval {
                            let ETAString = youngChildETA.stringFromTimeInterval(youngChildETA)
                            self.labelETA.text = "Other user is \(ETAString) from destination"
                            self.userArrival = self.calculateArrival(youngChildETA)
                            self.checkIfBothUserArrived()
                        }
                        
                    }
                    
                }

        })
        
        locationExactBase.observeEventType(.Value, withBlock: {
            snapshot in

            if let coordinateDistanceInString = snapshot.value as? String {
                let coordinateString = coordinateDistanceInString.componentsSeparatedByString("_coordinate_")
                
                if (coordinateString.count > 1) {
                    let latString = coordinateString[0]
                    let longString = coordinateString[1]
                    
                    let lat = (latString as NSString).doubleValue
                    let long = (longString as NSString).doubleValue
                    
                    let latDegrees: CLLocationDegrees = lat
                    let longDegrees: CLLocationDegrees = long
                    self.otherUserLocation = CLLocation(latitude: latDegrees, longitude: longDegrees)
                    
                    self.drawMap(self.myLocation, otherUserLocation: self.otherUserLocation, destinationLocation: self.destinationLocation)
                    
//                    print("Destination marker called")
                    let itemDist = self.otherUserLocation.distanceFromLocation(self.destinationLocation)
                    if (itemDist < 200) {
                        self.findDist(MKPlacemark(coordinate: self.otherUserLocation.coordinate, addressDictionary: nil), destination: self.destinationPlacemark, requestType: .Walking, title: "second")
                    } else {
                        self.findDist(MKPlacemark(coordinate: self.otherUserLocation.coordinate, addressDictionary: nil), destination: self.destinationPlacemark, requestType: .Automobile, title: "second")
                    }
                    self.otherUserAnnotation.coordinate = self.otherUserLocation.coordinate

                }
            }

        })
    }
    
}

extension MapTrackViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations.last!
        self.drawMap(self.myLocation, otherUserLocation: self.otherUserLocation, destinationLocation: self.destinationLocation)
        
        let userInfo = [self.appDelegate.userIdentifier: "\(myLocation.coordinate.latitude)_coordinate_\(myLocation.coordinate.longitude)"]
        self.locationFireBase.updateChildValues(userInfo)
        
        if let destination = destinationLocation {
            
            let itemDist = myLocation.distanceFromLocation(destination)
            
            if (itemDist < 200) {
                findDist(MKPlacemark(coordinate: myLocation.coordinate, addressDictionary: nil), destination: destinationPlacemark, requestType: .Walking, title: "first")
            } else {
                
                findDist(MKPlacemark(coordinate: myLocation.coordinate, addressDictionary: nil), destination: destinationPlacemark, requestType: .Automobile, title: "first")
            }
        }
        
        self.sourceAnnotation.coordinate = myLocation.coordinate
    }
    
}

extension MapTrackViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
        } else {
            // 3
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            if (annotation is MKUserLocation) {
                return nil
            } else {
                let colorPointAnnotation = annotation as! Annotation
                if (annotation.title! == "destination") {
                     view.pinTintColor = UIColor.greenColor()
                }
                if (annotation.title! == "Other User Location") {
//                    print("Painting other user location purple")
                    view.pinTintColor = UIColor.purpleColor()
                } else {
                    view.pinTintColor = colorPointAnnotation.color
                }
            }
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        return view
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        var polylineRenderer : MKPolylineRenderer!
        if overlay is MKPolyline {
            polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            if overlay.title! == "first" {
                polylineRenderer.strokeColor =
                    UIColor.blueColor().colorWithAlphaComponent(0.75)
            } else if overlay.title! == "second" {
                polylineRenderer.strokeColor =
                    UIColor.greenColor().colorWithAlphaComponent(0.75)
            }
            polylineRenderer.lineWidth = 4
            
            return polylineRenderer
        }
        return polylineRenderer
    }
    
    // Made by Dotun
    func findDist(source:MKPlacemark,destination:MKPlacemark,requestType:MKDirectionsTransportType,title:String) -> MKRoute?   {
        
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark:destination)
        
        request.transportType = requestType
        
        // get directions
        let directions = MKDirections(request: request)
        var quickestRouteForSegment: MKRoute?
        directions.calculateDirectionsWithCompletionHandler({
            (response:MKDirectionsResponse?, error:NSError?) in
            if let routeResponse = response?.routes {
                quickestRouteForSegment = routeResponse.sort({$0.expectedTravelTime < $1.expectedTravelTime})[0]
                quickestRouteForSegment?.polyline.title = title
                
                print("title: \(title) , expected time: \(quickestRouteForSegment?.expectedTravelTime)")
                self.labelFromETA((quickestRouteForSegment?.expectedTravelTime)!, title: title)
                
                var toRemove:MKOverlay!
                for overlay in self.theMap.overlays {
                    if (title == overlay.title!!) {
//                        print("overlay to remove \(title)")
                        toRemove = overlay
                    }
                }
                
                self.theMap.addOverlay(quickestRouteForSegment!.polyline)
                
                if (toRemove != nil) {
                    self.theMap.removeOverlay(toRemove)
                }

            } else {
                print ("could not display routes")
            }
        })
        
        return quickestRouteForSegment
    }
    
    func drawMap(myLocation:CLLocation?,otherUserLocation:CLLocation?,destinationLocation:CLLocation?) {
        
        var userPointRect: MKMapRect!
        var otherUserRect: MKMapRect!
        var destinationPointRect:MKMapRect!
        var unionAll:MKMapRect!
        
        if (myLocation != nil) {
            let userPoint = MKMapPointForCoordinate(myLocation!.coordinate)
            userPointRect = MKMapRectMake(userPoint.x, userPoint.y, 0, 0)
            unionAll = userPointRect
            theMap.centerCoordinate = (myLocation?.coordinate)!
        }
        
        if (otherUserLocation != nil) {
            let otherUserPoint = MKMapPointForCoordinate(otherUserLocation!.coordinate)
            otherUserRect = MKMapRectMake(otherUserPoint.x, otherUserPoint.y, 0, 0)
            
            if (unionAll != nil) {
                unionAll = MKMapRectUnion(unionAll,otherUserRect)
            } else {
                unionAll = otherUserRect
            }
        }
        
        if (destinationLocation != nil) {
            let destinationPoint = MKMapPointForCoordinate(destinationLocation!.coordinate)
            destinationPointRect = MKMapRectMake(destinationPoint.x, destinationPoint.y, 0,0)
            
            if (unionAll != nil) {
                unionAll = MKMapRectUnion(unionAll,destinationPointRect)
            } else {
                unionAll = destinationPointRect
            }
            
        }
        // set the region for visibility on map
        if let union = unionAll {
            let unionRectThatFits = theMap.mapRectThatFits(union)
            theMap.setVisibleMapRect(unionRectThatFits, edgePadding: UIEdgeInsetsMake(80.0, 80.0, 80.0, 80.0), animated: true)
        }
    }
    
}

extension NSTimeInterval {
    func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
//        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        var returnString = ""
        
        if (hours > 0) {
            returnString += "\(hours) hrs"
        }
        
        if (minutes > 0) {
            returnString += "\(minutes) mins"
        } else {
            returnString += "0 mins"
        }
//        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        return returnString
    }
}

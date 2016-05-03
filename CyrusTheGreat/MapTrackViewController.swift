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

class Annotation:NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var custom_image: Bool = true
    var color: UIColor = UIColor.blueColor()
    var title:String? = ""
}

class MapTrackViewController: UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var addressString:String!
    
    var destinationPlacemark:MKPlacemark!
    var destinationLocation:CLLocation!
    var myLocation: CLLocation!
    var otherUserLocation: CLLocation!
    
    var locationFireBase: Firebase!
   

    @IBOutlet weak var theMap: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        appDelegate.locationManager!.delegate = self
        appDelegate.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        appDelegate.locationManager.distanceFilter = 20 // Updates after moves 20 meters
        theMap.delegate = self
        theMap.mapType = MKMapType.Standard
        getDestinationCoordinateFromString(addressString)
        theMap.showsUserLocation = true
        appDelegate.locationManager!.startUpdatingLocation()
        // Do any additional setup after loading the view.
        
         locationFireBase = Firebase(url:"https://cyrusthegreat.firebaseio.com/location")
        fireBaseBusiness()
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
    
    func getDestinationCoordinateFromString(addressString:String) {
        if (addressString.isEmpty) {
            print("Address String presented is nil")
        } else {
            
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(addressString, completionHandler: {(placemarks, errors) in
                if let placemark = placemarks?[0]  {
                    self.destinationPlacemark = MKPlacemark(placemark: placemark)
                    self.destinationLocation = CLLocation(latitude: self.destinationPlacemark.coordinate.latitude, longitude: self.destinationPlacemark.coordinate.longitude)
                    let annotation = Annotation()
                    annotation.coordinate = self.destinationLocation.coordinate
                    annotation.title = "Destination"
                    annotation.color = UIColor.greenColor()
                    
                    
                    self.theMap.addAnnotation(annotation)
                }
            })
 
        }
        
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
            theMap.setVisibleMapRect(unionRectThatFits, edgePadding: UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0), animated: true)
            
        }
        
        
    }
    
    
    
    
    

}

extension MapTrackViewController {
    
    func fireBaseBusiness() {
        
//        let myLocationFireBase = locationFireBase.childByAppendingPath("\(UIDevice.currentDevice().name)")
        
        locationFireBase.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                
                if child.key != UIDevice.currentDevice().name {
                    
                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    
                     if let coordinateDistanceInString = childSnapshot.value as? String {
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
                            let annotation = Annotation()
                            annotation.coordinate = self.otherUserLocation.coordinate
                            annotation.title = "Other User Location"
                            annotation.color = UIColor.purpleColor()
                            
                            self.theMap.addAnnotation(annotation)
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            
            
            
        })
    }
    
    
}

extension MapTrackViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations.first!
//        CLLocation(latitude: destinationPlacemark.coordinate.latitude, longitude: destinationPlacemark.coordinate.longitude)
        self.drawMap(self.myLocation, otherUserLocation: self.otherUserLocation, destinationLocation: self.destinationLocation)
        
        let userInfo = [self.appDelegate.userIdentifier: "\(myLocation.coordinate.latitude)_coordinate_\(myLocation.coordinate.longitude)"]
        self.locationFireBase.updateChildValues(userInfo)
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
                view.pinTintColor = UIColor.blueColor()
            } else {
                let colorPointAnnotation = annotation as! Annotation
                view.pinTintColor = colorPointAnnotation.color
            }
           
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        return view
    }
    
}

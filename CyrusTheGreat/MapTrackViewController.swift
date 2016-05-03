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

class MapTrackViewController: UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var addressString:String!
    var destinationPlacemark:CLPlacemark!

    @IBOutlet weak var theMap: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.locationManager!.startUpdatingLocation()
        appDelegate.locationManager!.delegate = self
        appDelegate.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        theMap.delegate = self
        theMap.showsUserLocation = true
        theMap.mapType = MKMapType.Standard
        
        getDestinationCoordinateFromString(addressString)
        // Do any additional setup after loading the view.
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
                    self.destinationPlacemark = placemark
                    self.theMap.addAnnotation(MKPlacemark(placemark: placemark))
                }
            })
 
        }
        
    }

}

extension MapTrackViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        return view
    }
    
}

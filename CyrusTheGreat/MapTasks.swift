//
//  MapTasks.swift
//  GMapsDemo
//
//  Created by Gabriel Theodoropoulos on 29/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit


enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}

class MapTasks: NSObject {
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    
    override init() {
        super.init()
    }
    
    
    func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void)) {
        if let lookupAddress = address {
            var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
//            geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            geocodeURLString = geocodeURLString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            let geocodeURL = NSURL(string: geocodeURLString)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
                
//                var error: NSError?
                
                do {
                    
                    let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                    
                        // Get the response status.
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                            self.lookupAddressResults = allResults[0]
                            
                            // Keep the most important values.
                            self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
                            let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
                            self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                            self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
                    
                } catch {
                    
                    print(error)
                    completionHandler(status: "", success: false)
                    
                }
                
            })
        }
        else {
            completionHandler(status: "No valid address.", success: false)
        }
    }
    
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: TravelModes!, completionHandler: ((status: String, success: Bool) -> Void)) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "key=AIzaSyBNKALtaMqAXxDMy2jSaARp30xUjecbd8E" + "&origin=" + originLocation + "&destination=" + destinationLocation
                
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                
                if let _ = travelMode {
                    var travelModeString = ""
                    
                    switch travelMode.rawValue {
                    case TravelModes.walking.rawValue:
                        travelModeString = "walking"
                        
                    case TravelModes.bicycling.rawValue:
                        travelModeString = "bicycling"
                        
                    default:
                        travelModeString = "driving"
                    }
                    
                    
                    directionsURLString += "&mode=" + travelModeString
                }
                
//                directionsURLString += "key=AIzaSyBNKALtaMqAXxDMy2jSaARp30xUjecbd8E"
                
//                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                print(directionsURLString)
                directionsURLString = directionsURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                print(directionsURLString)
                let directionsURL = NSURL(string: directionsURLString)
                print (directionsURL!)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let directionsData = NSData(contentsOfURL: directionsURL!)
                    
//                    print(directionsData)
                    
//                    NSJSONSerialization.JSONObjectWithData(<#T##data: NSData##NSData#>, options: <#T##NSJSONReadingOptions#>)
                    
//                    var error: NSError?
                    
                    if let _ = directionsData {
                        do {
                            
                            let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                            
                            //                        if (error != nil) {
                            //                            print(error)
                            //                            completionHandler(status: "", success: false)
                            //                        }
                            //                        else {
                            let status = dictionary["status"] as! String
                            
                            if status == "OK" {
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                                
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"]as! Double, endLocationDictionary["lng"] as! Double)
                                
                                self.originAddress = legs[0]["start_address"] as! String
                                self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                
                                self.calculateTotalDistanceAndDuration()
                                
                                completionHandler(status: status, success: true)
                            }
                            else {
                                completionHandler(status: status, success: false)
                            }
                            //                        }
                            
                        } catch {
                            
                            print(error)
                            completionHandler(status: "", success: false)
                            
                        }
                        
                    }
                    

                   
                })
            }
            else {
                completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
    
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        var duration = ""
        
        if (days > 0) {
            duration += "\(days) d "
        }
        
        if (remainingHours > 0) {
            duration += " \(remainingHours) h "
        }
        
        if (remainingMins > 0) {
            duration += "\(remainingMins) mins "
        }
        if (remainingMins > 0) {
            duration += "\(remainingSecs) secs"
        }
        
        
        
//        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
        
        totalDuration = duration.trim()
        
       
    }
    
    
}

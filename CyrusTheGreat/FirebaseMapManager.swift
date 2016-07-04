//
//  FirebaseMapManager.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/12/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

protocol FirebaseMapDelegate {
    func updateOtherUserLocation(location:CLLocation)
    func updateETAInfo(ETA:NSTimeInterval)
}

class FirebaseMapManager: NSObject,NSCoding {
    var meetUpPathWay: FIRDatabaseReference!
    var etaPathFirebase : FIRDatabaseReference!
    var locationPathOtherUserFirebase : FIRDatabaseReference!
    var userId: String!
    var otherUserId:String!
    var delegate:FirebaseMapDelegate?
    var locationPath:FIRDatabaseReference!
    
    let locationString = "location"
    let etaToDestinationString = "etaToDestination"
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        if let userObject = aDecoder.decodeObjectForKey("currUserObjectId") {
            self.userId = userObject as! String
            
        }
        if let otherId = aDecoder.decodeObjectForKey("otherUserObjectId") {
            self.otherUserId = otherId as! String
        }
        
        if let userMeetUpPathway = aDecoder.decodeObjectForKey("cyrusMeetUpPathWay") {
            
            let meetUpUrl = userMeetUpPathway as! String
            meetUpPathWay = FIRDatabase.database().referenceFromURL(meetUpUrl)
            if (otherUserId != nil) {
                locationPath = meetUpPathWay.child(locationString)
                locationPathOtherUserFirebase = self.locationOtherUserFirebase()
                etaPathFirebase = etaToDestination()
                self.observeEtaOtherUser()
                self.observeLocationOtherUser()
            }
//            segueToQuestionNode = meetUpPathWay.child("segueToQuestion")
//            observeNextQuestionNode()
//            observeImageOtherUser()
        }
        
        
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userId, forKey: "currUserObjectId")
        aCoder.encodeObject(otherUserId, forKey: "otherUserObjectId")
        aCoder.encodeObject(meetUpPathWay.URL, forKey: "cyrusMeetUpPathWay")
    }
    
    
    
    
    init(meetPath:FIRDatabaseReference,myId:String,otherUserId:String) {
        super.init()
        meetUpPathWay = meetPath
        userId = myId
        self.otherUserId = otherUserId
        locationPath = meetUpPathWay.child(locationString)
        locationPathOtherUserFirebase = self.locationOtherUserFirebase()
        etaPathFirebase = etaToDestination()
        self.observeEtaOtherUser()
        self.observeLocationOtherUser()
    }
    
    func locationOtherUserFirebase() -> FIRDatabaseReference! {
        
        return locationPath.child("\(otherUserId)")
    }
    
    
    func etaToDestination() -> FIRDatabaseReference! {
        return meetUpPathWay.child(etaToDestinationString)
//            childByAppendingPath(etaToDestinationString)
    }
    
    func observeEtaOtherUser() {
        
        etaPathFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            for youngChild in snapshot.children {
            
                if youngChild.key != self.userId {

                    let youngChildSnapshot = snapshot.childSnapshotForPath(youngChild.key!!)
                    
                    if let youngChildETA = youngChildSnapshot.value as? NSTimeInterval {
                        
                        self.delegate?.updateETAInfo(youngChildETA)
                    }
                    
                }
                
            }
        })
    }
    
    func observeLocationOtherUser() {
        
        locationPathOtherUserFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            if let coordinateDistanceInString = snapshot.value as? String {
                
                let otherUserLocation = coordinateDistanceInString.stringToCLLocation()
                self.delegate?.updateOtherUserLocation(otherUserLocation)
                
            }
            
            
        })
        
    }
}

//
//  FirebaseMeetupManager.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/6/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class User: NSObject {
    var userId:String!
    var firstName:String!
    var schoolName:String!
    var location:CLLocation!
    var interests:[String]!
    var status:String!
    
}

class userProfile {
    var user:User!
    var userDistance:Double!
    var userMatchedInterest:[String]!
    var userMatchedCount:Int!
}

protocol FirebaseDelegate {
    func receiveInvite(inviter:String)
    func declineInvite()
    func segueToNextPage()
    func foundDisplay()
}

class FirebaseMeetupManager: NSObject {
    
    var userState:Firebase!
    var userActiveUser = Firebase(url:"https://cyrusthegreat.firebaseio.com/activeusers/")
    var userId:String?
    var userObject:User!
    var userFirebase:Firebase!
    var allFound = [userProfile]()
    var meetPathWay: Firebase!
    var fireBaseDelegate: FirebaseDelegate?
    var foundCount = 0
    var setReceiver = false
    
    
    
    func setUpCurrentUser(userId:String) {
        self.userId = userId
        print (userId)
        userFirebase = Firebase(url:"https://cyrusthegreat.firebaseio.com/users/\(userId)")
        
        userObject = User()
        
        userObject.userId = userId
        
        self.retrieveUserInfoFirebase()
       
    
    }
    
    private func retrieveUserInfoFirebase() {
        
        userFirebase.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                if (child.key == "first_name") {
                    self.userObject.firstName = childSnapshot.value as! String
                }
                
                if (child.key == "interests") {
                    self.userObject.interests = childSnapshot.value as! [String]
                    print("my interest:")
                    print (self.userObject.interests)
                }
                
                if (child.key == "school_name") {
                    self.userObject.schoolName = childSnapshot.value as! String
                }
            }
            
            print ("\(self.userObject.firstName) \(self.userObject.schoolName)")
            
        })
        
    }
    
    
    func updateUserState(userStatus:String){
        
        guard let myId = userId else {
            print("userId not set")
            return
        }
        
        userState = Firebase(url:"https://cyrusthegreat.firebaseio.com/users/\(myId)/status")
        userState.setValue(userStatus)
        userObject.status = userStatus
        userStateObserve()
    }
    
    func userStateObserve() {
        userState.observeEventType(.Value, withBlock: {
            snapshot in
            
            if let value = snapshot.value as? String {
//                if (value != self.userObject.status) {
                    self.userObject.status = value
                    print(self.userObject.status)
                    print(value == "Inviting")
                    if (value == "Inviting") {
                        
                        print ("You are getting an invite")
                    }
                    
                    if (value.contains("_meetup_")) {
                        let meetUpInfo = value.componentsSeparatedByString("_meetup_")
                        let meetUpPath = meetUpInfo[1]
                        print("abouta call meet path way")
                        self.meetPathWay = Firebase(url: meetUpPath)
                        self.observeMeetPath()
                    }
//                }
            }
        })
    }
    
    func updateUserLocation(location:CLLocation) {
        userObject.location = location
    }
    
    func updateChatMeetUp(status:String) {
        let chatStatus = ["chatMeetup": status ]
        self.meetPathWay.updateChildValues(chatStatus)
    }
    
    private func observeMeetPath() {
        
        meetPathWay.observeEventType(.Value, withBlock: {
            snapshot in
            print("meet path observed")
            for child in snapshot.children {
                print("child key is \(child.key)")
                if (child.key == "initiator") {
                    
                    print("child key is \(child.key) found inside")
                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    print(childSnapshot.value)
                    print(self.userObject.userId)
                    if let snap = childSnapshot.value as? String {
                        
                        if (snap != self.userObject.userId) {
                            
//                            Print meetUp Info with alert view
                            print("Observer for meet was called")
                            
                            if (!self.setReceiver) {
                                self.setReceiver = true
                                let receiverInfo = ["receiver": "\(self.userObject.userId)"]
                                print ("receiveInvite called")
                                
                                self.fireBaseDelegate?.receiveInvite(snap)
                                
                                self.meetPathWay.updateChildValues(receiverInfo)
                                
                            }
                            
                        }
                    }
                    
                    
                    
                }
                
                if (child.key == "chatMeetup") {
                    // print receiver info
                    
                    let childSnapshot = child.childSnapshotForPath(child.key)
                    
                    if let snap = childSnapshot.value as? String {
                        
                        if (snap == "Yes") {
                            // Segue to next page
                            self.fireBaseDelegate?.segueToNextPage()
//                            let userUpdate = [self.userObject.userId :nil]
                            self.removeActiveUser(self.userId!)
                            
                            
                        }
                        
                        if (snap == "No" ) {
                            // alert as No
                            self.fireBaseDelegate?.declineInvite()
                        }

                    }
                    
                    
                }
  
            }
 
            
        })
    }
    
    func removeActiveUser(userId:String) {
        let userExactPath = Firebase(url:"https://cyrusthegreat.firebaseio.com/activeusers/\(userId)")
        
        if (userExactPath == nil) {
            print ("not present")
        } else {
             userExactPath.removeValue()
        }
       
        
    }
//    func fireBaseCheck(otherUser:Firebase,inout found:Bool) {
//        otherUser.observeSingleEventOfType(.Value, withBlock: {
//            snapshot in
//            
//            let otherUserStatus = snapshot.value as! String
//            
//            
//            if (otherUserStatus == "Active") {
//                otherUser.setValue("Inviting")
//                found = true
//                print("I am in obsering single block")
//            }
//            
//        })
//        
//    }
    
    func meetUpClicked() {
        
        if (self.userObject.status == "Active") {
            var found = false
            var otherUser: Firebase!
            var otherUserUrl:String!
            for user in allFound {
                
                otherUser = Firebase(url:"https://cyrusthegreat.firebaseio.com/users/\(user.user.userId)/status")
                otherUserUrl = "https://cyrusthegreat.firebaseio.com/users/\(user.user.userId)/status.json"
                print(otherUserUrl)
                
                let url = NSURL(string:otherUserUrl)
                let data = NSData(contentsOfURL: url!)
                print(data)
                
                let otherUserStatus = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(otherUserStatus!)
                let otherUserString = otherUserStatus!.stringByReplacingOccurrencesOfString("\"", withString: "")
//                let otherUserString = String(otherUserStatus!)
                let realString = otherUserString.stringByReplacingOccurrencesOfString("\"", withString:"")
                print(realString == "Active")
                if (otherUserString == "Active") {
                    print("found other user and breaking out")
                    otherUser.setValue("Inviting")
                    found = true
                    break
                    
                    
                }
                
                
                
//                let json = JSON(data!)
//                print(json)
//                if json["metadata"]["responseInfo"]["status"].intValue == 200 {
//                    // we're OK to parse!
//                    print(json)
//                }
                
                
//            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
//                otherUser.observeSingleEventOfType(.Value, withBlock: {
//                    snapshot in
//                    
//                    let otherUserStatus = snapshot.value as! String
//                    
//                    
//                    if (otherUserStatus == "Active") {
//                        otherUser.setValue("Inviting")
//                        found = true
//                        print("I am in obsering single block")
//                    }
//                    
//                })
//                
//                if (found) {
//                    print("I am breaking because found")
//                    break
//                }
//            }
                
                
                
                
                
            }
//            
            if (found) {
                print("user found")
                updateUserState("Inviting")
                
                
                let generated = createMeetUp()
                
                let id = generated.description
                
                updateUserState("Inviting_meetup_\(id)")
                otherUser.setValue("Inviting_meetup_\(id)")
                
                let initiatorInfo = ["initiator": "\(userObject.userId)"]
                
                generated.updateChildValues(initiatorInfo)
                
            } else {
                print ("user not found")
            }
            
            
        } else {
            print ("User receiving invite")
        }
       
        
    }
    
    func createMeetUp() -> Firebase {
        let meetUp = Firebase(url: "https://cyrusthegreat.firebaseio.com/meetup/")
         return meetUp.childByAutoId()
    }
    
    
    
    
    
    
    // Call after everything is called
    func updateActiveUserFirebase() {
        print("Update active user called")
        guard let myId = userId else {
            print("userId not set")
            return
        }
        
        guard let _ = userObject.location else {
            print("location not set")
            return
        }
        
        var userArray = [String]()
        
        userArray.append("user_id_<separator>_\(userObject.userId)")
        userArray.append("name_<separator>_\(userObject.firstName)")
        userArray.append("schoolName_<separator>_\(userObject.schoolName)")
        userArray.append("location_<separator>_\(userObject.location.coordinate.latitude)_coordinate_\(userObject.location.coordinate.longitude)")
        let interests = userObject.interests.joinWithSeparator(",")
        userArray.append("interests_<separator>_\(interests)")

        let userIdLocation = [myId:userArray]
         print("Update active user called")
        userActiveUser.updateChildValues(userIdLocation)
        
    }
    
    func activateUserObserver() {
        
        guard let myId = userId else {
            print("userId not set")
            return
        }
    
        
        userActiveUser.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.allFound = [userProfile]()
            
            if (self.userObject != nil) {
                
                for child in snapshot.children {
                    
                    if child.key != myId {
                        let childSnapshot = snapshot.childSnapshotForPath(child.key)
                        
                        if let childValue = childSnapshot.value as? [String] {
                            let newFound = userProfile()
                            newFound.user = User()
                            
                            for userProp in childValue {
                                
                                let propInfo = userProp.componentsSeparatedByString("_<separator>_")
                                
                                if (userProp.contains("user_id")) {
                                    newFound.user.userId = propInfo[1]
                                    
                                }
                                
                                if (userProp.contains("name")) {
                                    newFound.user.firstName = propInfo[1]
                                }
                                if (userProp.contains("schoolName")) {
                                    newFound.user.schoolName = propInfo[1]
                                }
                                if (userProp.contains("interests")){
                                    let interestString = propInfo[1]
                                    let interests = interestString.componentsSeparatedByString(",")
                                    newFound.user.interests = interests

                                }
                                
                                if (userProp.contains("location")){
                                    let coordinateInString = propInfo[1]
                                    
                                    let coordinateString = coordinateInString.componentsSeparatedByString("_coordinate_")
                                    
                                    let latString = coordinateString[0]
                                    let longString = coordinateString[1]
                                    
                                    let lat = (latString as NSString).doubleValue
                                    let long = (longString as NSString).doubleValue
                                    
                                    let latDegrees: CLLocationDegrees = lat
                                    let longDegrees: CLLocationDegrees = long
                                    newFound.user.location = CLLocation(latitude: latDegrees, longitude: longDegrees)
                                    
                                }
                                
                            }
                            
                            if (newFound.user.schoolName == self.userObject.schoolName) {
                                
                                print ("Found other user with same institution")
                                let distance = newFound.user.location.distanceFromLocation(self.userObject.location)
                                print("distance is \(distance) from each other")
                                if (distance < 2000) {
                                    print (newFound.user.interests)
                                     let matchTopics =  self.findMatches(newFound.user.interests)
                                    print ("matched topics cout is \(matchTopics.count)")
                                    if (matchTopics.count > 0) {
                                      self.allFound.append(newFound)
                                    }
                                    
                                }
                                
                            }

                        }

                    }

                }
                
                self.sortAllFound()
            }
            self.foundCount = self.allFound.count
            self.fireBaseDelegate?.foundDisplay()
            print(self.allFound.count)

        })
    }
    
    
    
    
    // Sort by nearest Distance and most matched
    func sortAllFound() {
        allFound.sortInPlace({ (c1,c2) -> Bool in
            
            if (c1.userDistance < c2.userDistance) {
                return true
            } else if (c1.userDistance > c2.userDistance) {
                return false
            } else if (c1.userMatchedCount > c2.userMatchedCount) {
                return true
            }
            
            return false
        })
    }
    
    func findMatches(otherUserInterest:[String]) -> [String] {
        var matchTopics = [String]()
        for topic in otherUserInterest {
            if (userObject.interests.contains(topic)) {
                matchTopics.append(topic)
            }
            
        }
        
        return matchTopics
    }
    

}









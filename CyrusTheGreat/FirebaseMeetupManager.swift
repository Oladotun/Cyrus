//
//  FirebaseMeetupManager.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/6/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase

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
        
    }
    
    func userStateObserve() {
        userState.observeEventType(.Value, withBlock: {
            snapshot in
            
            if let value = snapshot.value as? String {
                if (value != self.userObject.status) {
                    self.userObject.status = value
                    
                    if (value == ("inviting")) {
                        
                        print ("You are getting an invite")
                    }
                    
                    if (value.contains("_meetup_")) {
                        let meetUpInfo = value.componentsSeparatedByString("_meetup_")
                        let meetUpPath = meetUpInfo[1]
                        
                        self.meetPathWay = Firebase(url: meetUpPath)
                        self.observeMeetPath()
                    }
                }
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
        var setReceiver = false
        meetPathWay.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                if (child.key == "initiator") {
                    let childSnapshot = child.childSnapshotForPath(child.key)
                    
                    if let snap = childSnapshot.value as? String {
                        
                        if (snap != self.userObject.userId) {
                            
//                            Print meetUp Info with alert view
                            
                            if (!setReceiver) {
                                setReceiver = true
                                let receiverInfo = ["receiver": "\(self.userObject.userId)"]
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
    
    
    func meetUpClicked() {
        
        if (self.userObject.status == "Active") {
            var found = false
            var otherUser: Firebase!
            for user in allFound {
                
                otherUser = Firebase(url:"https://cyrusthegreat.firebaseio.com/users/\(user.user.userId)")
                let otherUserStatus = otherUser.valueForKey("status") as! String
                
                if (otherUserStatus == "Active") {
                    otherUser.setValue("Inviting", forKey: "status")
                    found = true
                    break
                }
                
            }
            
            if (found) {
                print("user found")
                updateUserState("Inviting")
                
                
                let generated = createMeetUp()
                
                let id = generated.description
                
                updateUserState("Inviting_meetup_\(id)")
                otherUser.setValue("Inviting_meetup_\(id)", forKey: "status")
                
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
        
        guard let myId = userId else {
            print("userId not set")
            return
        }
        
        guard let _ = userObject.location else {
            print("location not set")
            return
        }

        let userIdLocation = [myId:userObject]
        userActiveUser.updateChildValues(userIdLocation)
        
    }
    
    func activeUserObserver() {
        
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
                        
                        if let childValue = childSnapshot.value as? User {
                            
                            if (childValue.schoolName == self.userObject.schoolName) {
                                
                                let distance = childValue.location.distanceFromLocation(self.userObject.location)
                                
                                if (distance < 2000) {
                                  let matchTopics =  self.findMatches(childValue.interests)
                                    
                                    if (matchTopics.count > 0) {
                                        let newFound = userProfile()
                                        newFound.user = childValue
                                        newFound.userDistance = distance
                                        newFound.userMatchedCount = matchTopics.count
                                        newFound.userMatchedInterest = matchTopics
                                        
                                        self.allFound.append(newFound)
                                    }
                                }
                            }

                        }

                    }
                    
                    
                }
                
                self.sortAllFound()
            }

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









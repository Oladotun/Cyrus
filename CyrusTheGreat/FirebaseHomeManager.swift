//
//  FirebaseHomeManager.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/12/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import Firebase
import CoreLocation
import UIKit

protocol FirebaseHomeDelegate {
    func receiveInvite(inviter:String)
    func declineInvite()
    func segueToNextPage()
    func foundDisplay()
}

class FirebaseHomeManager: NSObject {
    
    let cyrusUrl:String! = "https://cyrusthegreat.firebaseio.com/"
    let activeUserUrl = "https://cyrusthegreat.firebaseio.com/activeusers/"
    let invitingString = "Inviting"
    let activeString = "Active"
    let notActiveString = "Not Active"
    let chatMeetupString = "chatMeetup"
    let firstNameString = "firstName"
    let userIdString = "userId"
    let interestString = "interests"
    let locationString = "location"
    let schoolNameString = "schoolName"
    
    
    
    var userObject:User!
    var meetPathHandler:UInt!
    var userFirebase:Firebase!
    var allActiveUsers:Firebase!
    var userActiveFirebasePath:Firebase!
    var userStatusFirebase:Firebase!
    var meetUpPathWay:Firebase!
    var meetUpSet = false
    var setReceiver = false
    var userUrl:String!
    var userId:String!
    var iamInitiator:Bool!
    var connectedUserInfo:UserProfile!
    var allFound = [UserProfile]() // found profiles
    var delegate: FirebaseHomeDelegate?
    
    
    func setUpCurrentUser(userId:String) {
        
        self.userId = userId
        userUrl = "https://cyrusthegreat.firebaseio.com/users/\(userId)"
        userFirebase = Firebase(url:userUrl)
        allActiveUsers = Firebase(url: activeUserUrl)
        userObject = User()
        userObject.userId = userId
        self.retrieveUserInfoFirebase()
        
        
    }
    
    func retrieveUserInfoFirebase() {
        
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
            
        })
        
    }
    
    func updateUserState(userStatus:String){
        
        guard let _ = userId else {
//            print("userId not set")
            return
        }
        
        userStatusFirebase = Firebase(url:"\(userUrl)/status")
        userStatusFirebase.setValue(userStatus)
        userObject.status = userStatus
        userStatusFirebase.onDisconnectSetValue(notActiveString)
        observeUserStatusFirebase()
    }
    
    func observeUserStatusFirebase() {
        
        userStatusFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            if snapshot.childrenCount == 0  {
                
                if let value = snapshot.value as? String {
                    self.userObject.status = value
                }
                
            }
            
            if snapshot.childrenCount == 1 {
                
                for child in snapshot.children {
                    
                    if (child.key == self.invitingString && self.meetUpSet == false) {
                        let childSnapshot = snapshot.childSnapshotForPath(child.key)
                        
                        if let meetUpPath = childSnapshot.value as? String {
                            self.meetUpPathWay = Firebase(url: meetUpPath)
                            self.meetUpSet = true
                            self.observeMeetPath()
                            
                        }
                        
                    }
                    
                }
                
            }
            
        })
    }
    
    func observeMeetPath() {
        
        meetPathHandler = meetUpPathWay.observeEventType(.Value, withBlock: {
            snapshot in

            for child in snapshot.children {

                if (child.key == "initiator") {

                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    
                    if let snap = childSnapshot.value as? String {
                        
                        if (snap != self.userObject.userId) {
                            
                            if (!self.setReceiver) {
                                self.setReceiver = true
                                let receiverInfo = ["receiver": "\(self.userObject.userId)"]

                                for curr in self.allFound {
                                    if (curr.user.userId == snap ) {
                                         self.delegate?.receiveInvite(curr.user.firstName)
                                        self.connectedUserInfo = curr
                                    }
                                }
                                
                                self.meetUpPathWay.updateChildValues(receiverInfo)
                                
                            }
                            
                        }
                    }
                    
                }
                
                if (child.key == self.chatMeetupString) {
                    // print receiver info
                    
                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    
                    if let snap = childSnapshot.value as? String {
                        
                        if (snap == "Yes") {
                            // Initialize and Segue to next page
                            self.delegate?.segueToNextPage()
                            
                        }
                        
                        if (snap == "No" ) {
                            // alert as No
                            self.delegate?.declineInvite()
                        }
                        
                    }
                    
                }
                
            }
            
            
        })
    }
    
    func updateChatMeetUp(status:String) {
        let chatStatus = [chatMeetupString: status ]
        self.meetUpPathWay.updateChildValues(chatStatus)
    }
    
    func activateUserObserver() {
        
        guard let myId = userId else {
            NSException(name: "User ID not set", reason: "UserId has not been set properly", userInfo: nil).raise()
            return
        }
        
        allActiveUsers.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.allFound = [UserProfile]()
            
            if (self.userObject != nil) {
                
                for child in snapshot.children {
                    
                    if child.key != myId {
                        let childSnapshot = snapshot.childSnapshotForPath(child.key)
                        
                        if let childValue = childSnapshot.value as? [String:String] {
                            let newFound = UserProfile()
                            newFound.user = User()
                            newFound.user.schoolName = childValue[self.schoolNameString]
                            
                            if (self.userObject.schoolName != nil ) {
                                
                                if (newFound.user.schoolName == self.userObject.schoolName) {
                                    
                                    newFound.user.userId = childValue[self.userIdString]
                                    newFound.user.firstName = childValue[self.firstNameString]
                                    let coordinateInString = childValue[self.locationString]
                                    newFound.user.location = coordinateInString!.stringToCLLocation()
                                    
                                    let distance = newFound.user.location.distanceFromLocation(self.userObject.location)
                                    
                                    if (distance < 2000) {
                                        newFound.user.interests = (childValue[self.interestString])?.componentsSeparatedByString(",")
                                        let matchTopics =  self.findMatches(newFound.user.interests)
                                        
                                        if (matchTopics.count > 0) {
                                            newFound.userMatchedInterest = matchTopics
                                            newFound.userMatchedCount = matchTopics.count
                                            newFound.userDistance = distance
                                            self.allFound.append(newFound)
                                        }
                                        
                                    }
                                    
                                }
                            }

                        }
                        
                    }
                    
                }
                
                self.sortAllFound()
            }
            
            self.delegate?.foundDisplay()
            
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
    
    func removeActiveUser(userId:String) {
        let userExactPath = Firebase(url: "\(activeUserUrl)\(userId)")
    
        if(userExactPath != nil) {
        
            userExactPath.removeValue()
            
        }
        
        
    }
    
    
    func meetUpClicked() {
        
        if (self.userObject.status == activeString) {
            var found = false
            var otherUser: Firebase!
            var otherUserUrl:String!
            for user in allFound {
                
                otherUser = Firebase(url:"\(cyrusUrl)users/\(user.user.userId)/status")
                otherUserUrl = "\(cyrusUrl)users/\(user.user.userId)/status.json"

                let url = NSURL(string:otherUserUrl)
                let data = NSData(contentsOfURL: url!)

                let otherUserStatus = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                print(otherUserStatus!)
                let otherUserString = otherUserStatus!.stringByReplacingOccurrencesOfString("\"", withString: "")
                
                if (otherUserString == activeString) {
//                    print("found other user and breaking out")
                    otherUser.setValue(self.invitingString)
                    self.connectedUserInfo = user
                    found = true
                    break
                    
                }
            }
            //
            if (found) {
                self.userStatusFirebase.setValue(self.invitingString)
                self.meetUpPathWay = createMeetUp()
                let id = self.meetUpPathWay.description
                self.userStatusFirebase.setValue([self.invitingString: id])
                otherUser.setValue([self.invitingString: id])
                let initiatorInfo = ["initiator": "\(userObject.userId)"]
                self.iamInitiator = true
                
                self.meetUpPathWay.updateChildValues(initiatorInfo)
                
            }
//            else {
//                print ("user not found")
//            }
            
            
        }
//        else {
//            print ("User receiving invite")
//        }
//        
        
    }
    // Call after everything is called
    func updateActiveUserFirebase() {
//        print("Update active user called")
        guard let myId = userId else {
            NSException(name: "User ID not set", reason: "UserId has not been set properly", userInfo: nil).raise()
            return
        }
        
        guard let _ = userObject.location else {
            print("user location not set")
            return
        }
        
        //        var userArray = [String]()
        var userArray = [String : String]()
        userArray ["userId"] = userObject.userId
        userArray["firstName"] = userObject.firstName
        userArray["schoolName"] = userObject.schoolName
        userArray["location"] = "\(userObject.location.coordinate.latitude) \(userObject.location.coordinate.longitude)"
        userArray["interests"] = userObject.interests.joinWithSeparator(",")
        
        let userIdLocation = [myId:userArray]
        allActiveUsers.updateChildValues(userIdLocation)
        
        userActiveFirebasePath = allActiveUsers.childByAppendingPath(userId)
        userActiveFirebasePath.onDisconnectRemoveValue()
        
        
    }
    
    func removeMeetHandler() {
        guard let _ = meetPathHandler else {
            
             NSException(name: "Meet up handler not set", reason: "Handler not set", userInfo: nil).raise()
            return
        }
        
        meetUpPathWay.removeObserverWithHandle(meetPathHandler)
    }
    
    func createMeetUp() -> Firebase {
        let meetUp = Firebase(url: "\(cyrusUrl)meetup/")
        return meetUp.childByAutoId()
    }
    
    func updateUserLocation(location:CLLocation) {
        userObject.location = location
    }
    
    

}

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
import CoreLocation

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

protocol FirebaseHomeDelegate {
    func receiveInvite(inviter:String)
    func declineInvite()
    func segueToNextPage()
    func foundDisplay()
}

protocol FirebaseChatDelegate {
    func updateChat(chatMsg:String, location:CLLocation)
    var iamSender : Bool! {get set}
    func segueToNextPage()
    func meetUpCancelled(canceller:String)
}

protocol FirebaseMapDelegate {
    func updateOtherUserLocation(location:CLLocation)
    func updateETAInfo(ETA:NSTimeInterval)
}

protocol FirebaseQuestionDelegate {
    func updateQuestionLabel(question:String)
    func chattingDone()
    func meetUpCancelled(canceller:String)
}

class FirebaseManager: NSObject {
    
    var userState:Firebase!
    var userActiveUser = Firebase(url:"https://cyrusthegreat.firebaseio.com/activeusers/")
    var userId:String?
    var userObject:User!
    var userFirebase:Firebase!
    var allFound = [userProfile]()
    var meetPathWay: Firebase!
    var fireBaseDelegate: FirebaseHomeDelegate?
    var fireBaseChatDelegate: FirebaseChatDelegate?
    var fireBaseOtherUserLocationDelegate: FirebaseMapDelegate?
    var fireBaseQuestDelegate: FirebaseQuestionDelegate?
    var foundCount = 0
    var setReceiver = false
    var meetUpSet = false
    var connectedUserInfo:userProfile!
    var chatMessagePathFirebase:Firebase!
    var chatAcceptPathFirebase:Firebase!
    var myLocationPath:Firebase!
    var locationPathOtherUserFirebase:Firebase!
    var etaPathFirebase:Firebase!
    var questionPathFirebase: Firebase!
    var meetPathHandler:UInt!
    var iamInitiator = false
    var userActiveFirebasePath:Firebase!
    
    
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
        userState.onDisconnectSetValue("Not Active")
        userStateObserve()
    }
    
    func userStateObserve() {
//        var count = 0
        userState.observeEventType(.Value, withBlock: {
            snapshot in
//            count = count + 1
//            print ("number of times called \(count)")
            
            if let value = snapshot.value as? String {
                    self.userObject.status = value
                    print(self.userObject.status)
                    print(value == "Inviting")
                    if (value == "Inviting") {
                        
                        print ("You are getting an invite")
                    }
                    
                    if (value.contains("_meetup_") && self.meetUpSet == false) {
                        let meetUpInfo = value.componentsSeparatedByString("_meetup_")
                        let meetUpPath = meetUpInfo[1]
                        print("abouta call meet path way from userStateObserve")
                        
                        self.meetPathWay = Firebase(url: meetUpPath)
//                        self.meetPathWay.onDisconnectRemoveValue() // Removef
                        self.meetUpSet = true
                        self.observeMeetPath()
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
    
    func removeMeetHandler() {
        guard let _ = meetPathHandler else {
            
            print("handler was not set")
            return
        }
        
        meetPathWay.removeObserverWithHandle(meetPathHandler)
    }
    
    func observeChatMsgPath() {
        guard let _ = self.chatMessagePathFirebase else {
            print("chat message path not set")
            return
        }         
        chatMessagePathFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                if (child.key != self.userId) {
                    if let value = childSnapshot.value as? [String:String] {
                        self.fireBaseChatDelegate?.iamSender = false
                        let destinationLocation = (value["location"])?.stringToCLLocation()
                        let chatMsg = value["message"]
                        
                        self.fireBaseChatDelegate?.updateChat(chatMsg!,location: destinationLocation!)
                    }
                    
                }
                
            }

        })
        
    }
    
    func updateChatMsgPath(msg:String,toSend:[String:String]) {
        
        let info = [msg : toSend]
        chatMessagePathFirebase.setValue(info)
    }
    
    func meetUpPropInitialize() {
        self.chatMessagePathFirebase = self.chatMessagePath()
        self.chatAcceptPathFirebase = self.chatAcceptPath()
        self.locationPathOtherUserFirebase = myLocationUserFirebase()
        self.myLocationPath = meetPathWay.childByAppendingPath("location")
        self.etaPathFirebase = self.etaToDestination()
        self.questionPathFirebase = self.questionUserFirebase()
        self.fireBaseDelegate?.segueToNextPage()
        self.observeChatMsgPath()
        self.observeChatAcceptPathObserve()
//        self.observeQuestionFirebase()
        self.removeActiveUser(self.userId!)
    }
    
    func questionUserFirebase() -> Firebase! {
        return meetPathWay.childByAppendingPath("question")
    }
    
    func observeQuestionFirebase() {
        questionPathFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
                if let value = snapshot.value as? String {
                    
                    if (value.contains("_end_chat_")) {
                        let userInfo = value.componentsSeparatedByString("_end_chat_")
                        self.fireBaseQuestDelegate?.meetUpCancelled(userInfo[0])
                    }
                    
                if (!self.iamInitiator) {
                    if (value.contains("_Done_")) {
                        self.fireBaseQuestDelegate?.chattingDone()
                    
                    } else {
                        print("\(value)") // call  question delegate
                        self.fireBaseQuestDelegate?.updateQuestionLabel(value)
                    
                    }

                }
                
            }
            
        })
    }
    
    func locationOtherUserFirebase() -> Firebase! {
        
        return meetPathWay.childByAppendingPath("location").childByAppendingPath(connectedUserInfo.user.userId)
    }
    
    func myLocationUserFirebase() -> Firebase! {
        
        return meetPathWay.childByAppendingPath("location").childByAppendingPath(self.userId)
        
    }
    
    func etaToDestination() -> Firebase! {
        return meetPathWay.childByAppendingPath("etaToDestination")
    }
    
    func observeEtaOtherUser() {
        print("observing eta other user")
        etaPathFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            for youngChild in snapshot.children {
                
                print(youngChild.key)
                print(self.userId)
                if youngChild.key != self.userId {
                    print("I got called out")
                    let youngChildSnapshot = snapshot.childSnapshotForPath(youngChild.key)
                    
                    if let youngChildETA = youngChildSnapshot.value as? NSTimeInterval {
                        
                        self.fireBaseOtherUserLocationDelegate?.updateETAInfo(youngChildETA)
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
                    self.fireBaseOtherUserLocationDelegate?.updateOtherUserLocation(otherUserLocation)
                
                }
            
            
        })
        
    }
    
    private func observeMeetPath() {
        
        meetPathHandler = meetPathWay.observeEventType(.Value, withBlock: {
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
                                
                                for curr in self.allFound {
                                    if (curr.user.userId == snap ) {
                                        self.connectedUserInfo = curr
                                    }
                                }
                                
                                self.meetPathWay.updateChildValues(receiverInfo)
                                
                            }
                            
                        }
                    }
 
                }
                
                if (child.key == "chatMeetup") {
                    // print receiver info
                    
                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    
                    if let snap = childSnapshot.value as? String {
                        
                        if (snap == "Yes") {
                            // Initialize and Segue to next page
                            self.meetUpPropInitialize()

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
    
    func updateChatAccept(value:String) {
        chatAcceptPathFirebase.setValue(value)
    }
    
    func observeChatAcceptPathObserve() {
        
        var yesCalled = false
        
        chatAcceptPathFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            if (!snapshot.value.isEqual(NSNull()) ) {
                
                if(snapshot.value as! String == "Yes") && !yesCalled {
                    
                    self.fireBaseChatDelegate?.segueToNextPage()
                    yesCalled = true
                    
                }
                
                if(snapshot.value as! String == "No") {
                    
                }
                
                if((snapshot.value as! String).contains("_end_chat_")) {
                    
                    let endWord = snapshot.value as! String
                    
                    let splitEndWord = endWord.componentsSeparatedByString("*_*")
                    // user x ended the chat
                    print("\(splitEndWord)")
                    self.fireBaseChatDelegate?.meetUpCancelled(splitEndWord[0])
                
                    
                }
            }
            

            
            
        })
        
    }
    
    func chatAcceptPath() -> Firebase! {
        guard let _ = meetPathWay else {
            NSException(name: "Meet up not set in Chat Accept", reason: "Meet up info not set", userInfo: nil).raise()
            return nil
        }
        return meetPathWay.childByAppendingPath("chatAccept")
        
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
                
                if (otherUserString == "Active") {
                    print("found other user and breaking out")
                    otherUser.setValue("Inviting")
                    self.connectedUserInfo = user
                    found = true
                    break
  
                }
            }
//            
            if (found) {
                print("user found")
                updateUserState("Inviting")
                
                
                self.meetPathWay = createMeetUp()
                
                let id = self.meetPathWay.description
                
                updateUserState("Inviting_meetup_\(id)")
                otherUser.setValue("Inviting_meetup_\(id)")
                self.chatMessagePathFirebase = self.chatMessagePath()
                let initiatorInfo = ["initiator": "\(userObject.userId)"]
                self.iamInitiator = true
                
                self.meetPathWay.updateChildValues(initiatorInfo)
                
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
    
    
    func chatMessagePath() -> Firebase! {
        guard let _ = meetPathWay else {
            NSException(name: "Meet up not set", reason: "Meet up info not set", userInfo: nil).raise()
            return nil
        }
        return meetPathWay.childByAppendingPath("chatMsg")
    }

    
    // Call after everything is called
    func updateActiveUserFirebase() {
        print("Update active user called")
        guard let myId = userId else {
            NSException(name: "User ID not set", reason: "UserId has not been set properly", userInfo: nil).raise()
            return
        }
        
        guard let _ = userObject.location else {
            print("location not set")
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
         print("Update active user called")
         userActiveUser.updateChildValues(userIdLocation)
        
        userActiveFirebasePath = userActiveUser.childByAppendingPath(userId)
         userActiveFirebasePath.onDisconnectRemoveValue()

    
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
                        
                        if let childValue = childSnapshot.value as? [String:String] {
                            
                            print(childValue)
                            let newFound = userProfile()
                            newFound.user = User()
                            newFound.user.schoolName = childValue["schoolName"]
                            
                            if (newFound.user.schoolName == self.userObject.schoolName) {
                                
                                newFound.user.userId = childValue["userId"]
                                newFound.user.firstName = childValue["firstName"]
                                let coordinateInString = childValue["location"]
                                newFound.user.location = coordinateInString!.stringToCLLocation()
                                
                                let distance = newFound.user.location.distanceFromLocation(self.userObject.location)
                                
                                if (distance < 2000) {
                                    newFound.user.interests = (childValue["interests"])?.componentsSeparatedByString(",")
                                    let matchTopics =  self.findMatches(newFound.user.interests)
                                    print ("matched topics cout is \(matchTopics.count)")
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

extension String {
    func stringToCLLocation() -> CLLocation{
        let coordinateString = self.componentsSeparatedByString(" ")
        
        if (coordinateString.count < 2) {
            NSException(name: "Coordinate String Array Error", reason: "The coordinate string after split contains 1 or less elements", userInfo: nil).raise()
        }
        
        let latString = coordinateString[0]
        let longString = coordinateString[1]
        
        let lat = (latString as NSString).doubleValue
        let long = (longString as NSString).doubleValue
        
        let latDegrees: CLLocationDegrees = lat
        let longDegrees: CLLocationDegrees = long
        
        return CLLocation(latitude: latDegrees, longitude: longDegrees)
        
    }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}









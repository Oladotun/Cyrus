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
    var foundCount = 0
    var setReceiver = false
    var meetUpSet = false
    var connectedUserInfo:userProfile!
    var chatMessagePathFirebase:Firebase!
    var chatAcceptPathFirebase:Firebase!
    var meetPathHandler:UInt!
    
    
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
                        print("abouta call meet path way")
                        
                        self.meetPathWay = Firebase(url: meetUpPath)
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
            if let val = snapshot.value as? String {
                
                if (!val.isEmpty) {
                    let sendMsg = val.componentsSeparatedByString("_value_")
                    
                    if (sendMsg.count > 1) {
                        if(sendMsg[0] != self.userId ){
                            self.fireBaseChatDelegate?.iamSender = false
                            
                            if (sendMsg[1].contains("^_^")) {
                                
                                var itemAdd = sendMsg[1].componentsSeparatedByString("^_^")
                                print(itemAdd[1])
                                
                                if (itemAdd.count > 1) {
                                    
                                    if (itemAdd[1].contains("*_*")) {
                                        
                                        let coordinateString = itemAdd[1].componentsSeparatedByString("*_*")
                                        let latString = coordinateString[0]
                                        let longString = coordinateString[1]
                                        let lat = (latString as NSString).doubleValue
                                        let long = (longString as NSString).doubleValue
                                        
                                        let latDegrees: CLLocationDegrees = lat
                                        let longDegrees: CLLocationDegrees = long
                                        let destinationLocation = CLLocation(latitude: latDegrees, longitude: longDegrees)
                                        
                                        //Update view after everything
                                        self.fireBaseChatDelegate?.updateChat(itemAdd[0],location: destinationLocation)
                                        
                                    }
                                    
                                }
 
                            }
 
                        } 
                        
                    }
                    
                } else {
                    print("Message path not set")
                }
                
            }
        })
        
    }
    
    func updateChatMsgPath(msg:String) {
        chatMessagePathFirebase.setValue(msg)
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
                            // Segue to next page
                            self.chatMessagePathFirebase = self.chatMessagePath()
                            self.chatAcceptPathFirebase = self.chatAcceptPath()
                            self.fireBaseDelegate?.segueToNextPage()
                            self.observeChatMsgPath()
                            self.observeChatAcceptPathObserve()
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
            print("meet up not set")
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
                
                
                let generated = createMeetUp()
                
                let id = generated.description
                
                updateUserState("Inviting_meetup_\(id)")
                otherUser.setValue("Inviting_meetup_\(id)")
                self.chatMessagePathFirebase = self.chatMessagePath()
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
    
    
    func chatMessagePath() -> Firebase! {
        guard let _ = meetPathWay else {
            print("meet up not set")
            return nil
        }
        return meetPathWay.childByAppendingPath("chatMsg")
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

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}









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
    func receiveInvite(invitedUser:UserProfile)
    func declineInvite()
    func segueToNextPage()
    func foundDisplay()
    func setImage(image:UIImage)
    
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
    let userFieldString = "userField"
    
    
    
    var userObject:User!
    var userMetUpWith = [String]()
    var meetPathHandler:UInt!
    
    
    var userFirebase:FIRDatabaseReference!
    var userMetUpWithFirebase:FIRDatabaseReference!
    var allActiveUsers:FIRDatabaseReference!
    var userActiveFirebasePath:FIRDatabaseReference!
    var userStatusFirebase:FIRDatabaseReference!
    var meetUpPathWay:FIRDatabaseReference!
    var meetUpSet = false
    var setReceiver = false
    var userUrl:String!
    var userId:String!
    var iamInitiator:Bool!
    var activeUserListActivated = false
    var connectedUserInfo:UserProfile!
    var allFound = [UserProfile]() // found profiles
    var delegate: FirebaseHomeDelegate?
    var declineList = [UserProfile]() // Decline profiles
    var activeUserCalled = false
    
    var countInitial = 0
    
    func setUpCurrentUser(userId:String) {
        
        self.userId = userId
        userUrl = "https://cyrusthegreat.firebaseio.com/users/\(userId)"
        userFirebase = FIRDatabase.database().referenceFromURL(userUrl)
        allActiveUsers = FIRDatabase.database().referenceFromURL(activeUserUrl)
        userObject = User()
        userObject.userId = userId
//        print("https://cyrusthegreat.firebaseio.com/users/\(userId)")
        self.retrieveUserInfoFirebase()
               
        
    }
    
    func getMyImageUser() {

        let storage = FIRStorage.storage()
        let imageRef = storage.referenceForURL("gs://project-5582715640635114460.appspot.com/\(userId).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let myImage: UIImage! = UIImage(data: data!)
                self.delegate?.setImage(myImage)
               
                
            }
        }
        

        
    }
    
    
    
    func retrieveUserInfoFirebase() {
        userFirebase.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                let childSnapshot = snapshot.childSnapshotForPath(child.key!!)
                
                if (child.key == "first_name") {
                    self.userObject.firstName = childSnapshot.value as! String
                    self.countInitial = self.countInitial + 1
//                    print("first name called")
                }
                
                if (child.key == "interests") {
                    self.userObject.interests = childSnapshot.value as! [String]
                     self.countInitial = self.countInitial + 2
//                     print("interests")
                }
                
                if (child.key == "school_name") {
                    self.userObject.schoolName = childSnapshot.value as! String
                     self.countInitial = self.countInitial + 3
//                    print("school name")
                }
                
                if (child.key == "field_study") {
                    self.userObject.userField = childSnapshot.value as! String
                     self.countInitial = self.countInitial + 4
//                    print("study field")
                    
                }
                
                if (child.key == "metup_with") {
                    self.userMetUpWith = childSnapshot.value as! [String]
                     self.countInitial = self.countInitial + 6
                }
                
          
                
                if (self.countInitial > 9 && self.activeUserCalled) {
                    self.updateActiveUserFirebase()
                    
                }
                
                
            }
            
        })
        
    }
    
    func updateMetUpWith(userIdMet:String) {
        userMetUpWithFirebase = FIRDatabase.database().referenceFromURL("\(userUrl)/metup_with")
//            Firebase(url:"\(userUrl)/metup_with")
        userMetUpWith.append(userIdMet)
//        userMetUpWithFirebase.setValue(userMetUpWith)
        let userMeetUpCount = FIRDatabase.database().referenceFromURL("\(userUrl)/metup_with_count")
        userFirebase.updateChildValues(["metup_with":userMetUpWith])
        userMeetUpCount.updateChildValues(["metup_with_count":userMetUpWith.count])
        self.delegate?.foundDisplay()
        
        
    }
    
    func updateUserState(userStatus:String){
        
        guard let _ = userId else {
            return
        }
        
        userStatusFirebase = FIRDatabase.database().referenceFromURL("\(userUrl)/status")

//            Firebase(url:"\(userUrl)/status")
        userFirebase.updateChildValues(["status":userStatus])
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
                        let childSnapshot = snapshot.childSnapshotForPath(child.key!!)
                        if let meetUpPath = childSnapshot.value as? String {
                            self.meetUpPathWay = FIRDatabase.database().referenceFromURL(meetUpPath)
//                                Firebase(url: meetUpPath)
                            self.meetUpSet = true
                            self.observeMeetPath()
                            
                        }
                        
                    }
                    
                }
                
            }
            
        })
    }
    
    func observeMeetPath() {
        var nextPagePath = false
        meetPathHandler = meetUpPathWay.observeEventType(.Value, withBlock: {
            snapshot in

            for child in snapshot.children {

                if (child.key == "initiator") {

                    let childSnapshot = snapshot.childSnapshotForPath(child.key!!)
                    
                    if let snap = childSnapshot.value as? String {
                        
                        if (snap != self.userObject.userId) {
                            
                            if (!self.setReceiver) {
                                self.setReceiver = true
                                let receiverInfo = ["receiver": "\(self.userObject.userId)"]

                                for curr in self.allFound {
                                    if (curr.user.userId == snap ) {
                                        self.delegate?.receiveInvite(curr)
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
                    
                    let childSnapshot = snapshot.childSnapshotForPath(child.key!!)
                    
                    if let snap = childSnapshot.value as? String {
                        
                        if (snap == "Yes" && !nextPagePath) {
                            // Initialize and Segue to next page
//                            print("going to next page")
                            nextPagePath = true
                            self.delegate?.segueToNextPage()
                            
                        }
                        
                        if (snap == "No" && !nextPagePath) {
                            // alert as No
                            self.delegate?.declineInvite()
                            self.declineList.append(self.connectedUserInfo)
                            self.allFound = self.allFound.filter{ $0.user.userId != self.connectedUserInfo.user.userId} // filter out  unfound user
                            self.delegate?.foundDisplay()
                            nextPagePath = true
                            self.updateUserState("Active")
                            
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
    
    func checkMetUpWithList(userId:String) -> Bool {
        for user in userMetUpWith  {
            if (user == userId) {
                return true
            }
        }
        
        return false
        
    }
    
    func activateUserObserver() {
        

        guard let myId = userId else {
            NSException(name: "User ID not set", reason: "UserId has not been set properly", userInfo: nil).raise()
            return
        }
        
        allActiveUsers.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.allFound = [UserProfile]()
            
            if (!self.activeUserListActivated) {
                self.activeUserListActivated = true
            }
            
            if (self.userObject != nil) {
               
                for child in snapshot.children {
                    
                    if child.key != myId {
                        let childSnapshot = snapshot.childSnapshotForPath(child.key!!)
                        
                        if let childValue = childSnapshot.value as? [String:String] {
                            let userId = childValue[self.userIdString]! as String
                            
                            if (!self.checkDeclineList(userId) && !self.checkMetUpWithList(userId)) {
                                
                                let newFound = UserProfile()
                                
                                newFound.user = User()
                                newFound.user.userId = childValue[self.userIdString]
                                newFound.user.schoolName = childValue[self.schoolNameString]
                                
                                if (self.userObject.schoolName != nil ) {
                                    
                                    if (newFound.user.schoolName == self.userObject.schoolName) {
                                        
//                                        print("Found user with the same school name")
                                        
                                        newFound.user.firstName = childValue[self.firstNameString]
                                        newFound.user.userField = childValue[self.userFieldString]
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
                                
            }
                            
            
            self.delegate?.foundDisplay()
            
        })
        
    }
    
    func checkDeclineList(userId:String) -> Bool  {
        for user in declineList {
            if (user.user.userId == userId) {
                return true
            }
        }
        
        return false
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
        let userExactPath = FIRDatabase.database().referenceFromURL("\(activeUserUrl)\(userId)")
//        Firebase(url: "\(activeUserUrl)\(userId)")
    
        userExactPath.removeValue()
        activeUserCalled = false
        
        
    }
    
    
    func meetUpClicked() {
        
        if (self.userObject.status == activeString) {
            var found = false
            var otherUser: FIRDatabaseReference!
            var otherUserUrl:String!
            for user in allFound {
                
                otherUser =  FIRDatabase.database().referenceFromURL("\(cyrusUrl)users/\(user.user.userId)/status")
                otherUserUrl = "\(cyrusUrl)users/\(user.user.userId)/status.json"

                let url = NSURL(string:otherUserUrl)
                let data = NSData(contentsOfURL: url!)

                let otherUserStatus = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let otherUserString = otherUserStatus!.stringByReplacingOccurrencesOfString("\"", withString: "")
                
                if (otherUserString == activeString) {
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
            
        }
        
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
        activeUserCalled = true
        
        if (countInitial < 10) {
            print(countInitial)
            print("Not all set")
            return
        }
        
        //        var userArray = [String]()
        var userArray = [String : String]()
        userArray ["userId"] = userObject.userId
        userArray["firstName"] = userObject.firstName
        userArray["schoolName"] = userObject.schoolName
        userArray["userField"] = userObject.userField
        userArray["location"] = "\(userObject.location.coordinate.latitude) \(userObject.location.coordinate.longitude)"
        userArray["interests"] = userObject.interests.joinWithSeparator(",")
    
        
//        let userIdLocation = [myId:userArray]
        allActiveUsers.child(myId).updateChildValues(userArray)
        
        userActiveFirebasePath = allActiveUsers.child(userId)
//            childByAppendingPath(userId)
        userActiveFirebasePath.onDisconnectRemoveValue()
        
        
    }
    
    func removeMeetHandler() {
        guard let _ = meetPathHandler else {
            
             NSException(name: "Meet up handler not set", reason: "Handler not set", userInfo: nil).raise()
            return
        }
        
        meetUpPathWay.removeObserverWithHandle(meetPathHandler)
    }
    
    func createMeetUp() -> FIRDatabaseReference {
        let meetUp = FIRDatabase.database().referenceFromURL("\(cyrusUrl)meetup/")
//        Firebase(url: "\(cyrusUrl)meetup/")
        return meetUp.childByAutoId()
    }
    
    func updateUserLocation(location:CLLocation) {
        userObject.location = location
        
    }

}

extension String {
    func stringToImage() -> UIImage {
        let dataDecoded:NSData? = NSData(base64EncodedString: self, options:.IgnoreUnknownCharacters)
        let decodedimage:UIImage = UIImage(data: dataDecoded!)!
        return decodedimage
        
    }
}

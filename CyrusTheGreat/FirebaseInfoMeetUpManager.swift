//
//  FirebaseInfoMeetUpManager.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/13/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase
protocol FirebaseInfoMeetUpManagerDelegate {
    
    func segueToNext()
    func alertOtherUserArrival()
    func updateOtherUserImage(image:UIImage)
    func meetUpCancelled(canceller:String)
    
}

class FirebaseInfoMeetUpManager: NSObject,NSCoding {
    
    var meetUpPathWay:FIRDatabaseReference!
    var segueToQuestionNode:FIRDatabaseReference!
    var segueCancelMeetUp: FIRDatabaseReference!
    var delegate:FirebaseInfoMeetUpManagerDelegate?
    var userId:String!
    var otherUserId:String!
    var questionTime:Bool!
    
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
            segueToQuestionNode = meetUpPathWay.child("segueToQuestion")
            segueCancelMeetUp = meetUpPathWay.child("pathWayCancelMeet")
            observeNextQuestionNode()
            observeImageOtherUser()
        }
        
         questionTime = aDecoder.decodeBoolForKey("questionTime")
         
        
        
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userId, forKey: "currUserObjectId")
        aCoder.encodeObject(otherUserId, forKey: "otherUserObjectId")
        aCoder.encodeObject(meetUpPathWay.URL, forKey: "cyrusMeetUpPathWay")
        aCoder.encodeBool(questionTime, forKey: "questionTime")
    }
    
    
    
    init(meetPath:FIRDatabaseReference,myId:String,otherUserId:String) {
        super.init()
        meetUpPathWay = meetPath
        segueToQuestionNode = meetUpPathWay.child("segueToQuestion")
        segueCancelMeetUp = meetUpPathWay.child("pathWayCancelMeet")
        userId = myId
        self.questionTime = false
        self.otherUserId = otherUserId
        observeNextQuestionNode()
        observeImageOtherUser()
    }
    

    
    func observeImageOtherUser() {
        
        let storage = FIRStorage.storage()
        let imageRef = storage.referenceForURL("gs://project-5582715640635114460.appspot.com/\(otherUserId).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.dataWithMaxSize(3 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let myImage: UIImage! = UIImage(data: data!)
                self.delegate?.updateOtherUserImage(myImage)
                
                
            }
        }
        
    }
    func observeCancelMeetuPNode() {
        segueCancelMeetUp.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {

                let childSnapshot = snapshot.childSnapshotForPath(child.key!!)
                
                if let childValue = childSnapshot.value as? String {
                    
                    if (childValue.contains("_end_chat_")) {
                        let childKey :String = child.key!!
                        self.delegate?.meetUpCancelled(childKey)
                    }
                    
                }

            }
        })
    }
    
    func observeNextQuestionNode() {
        
        segueToQuestionNode.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                if (child.key != self.userId) {
                    let childSnapshot = snapshot.childSnapshotForPath(child.key!!)
                    
                    if let readyQuest = childSnapshot.value as? Bool {
                        
                        if (readyQuest == true && self.questionTime == true) {
                            
                            self.delegate?.segueToNext()
                        } else {
                            self.delegate?.alertOtherUserArrival()
                        }
                    }
                }
            }
        })
        
    }
    
}

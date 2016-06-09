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
    func updateMyImage(image:UIImage)
    func updateOtherUserImage(image:UIImage)
    
}

class FirebaseInfoMeetUpManager: NSObject {
    
    var meetUpPathWay:Firebase!
    var segueToQuestionNode:Firebase!
    var delegate:FirebaseInfoMeetUpManagerDelegate?
    var userId:String!
    var otherUserId:String!
    var questionTime:Bool!
    
    init(meetPath:Firebase,myId:String,otherUserId:String) {
        super.init()
        meetUpPathWay = meetPath
        segueToQuestionNode = meetUpPathWay.childByAppendingPath("segueToQuestion")
        userId = myId
        self.otherUserId = otherUserId
        observeNextQuestionNode()
        observeImageUser()
        observeImageOtherUser()
    }
    
    func observeImageUser() {
        
        let userUrl = "https://cyrusthegreat.firebaseio.com/users/\(userId)/image"
        let userFirebase = Firebase(url:userUrl)
        
        userFirebase.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            let imageString = snapshot.value as! String
            let image = imageString.stringToImage()
            self.delegate?.updateMyImage(image)
        })
        
    }
    
    func observeImageOtherUser() {
        let userUrl = "https://cyrusthegreat.firebaseio.com/users/\(otherUserId)/image"
        let userFirebase = Firebase(url:userUrl)
        
        userFirebase.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            let imageString = snapshot.value as! String
            let image = imageString.stringToImage()
            self.delegate?.updateOtherUserImage(image)
        })
        
    }
    
    func observeNextQuestionNode() {
        
        segueToQuestionNode.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                if (child.key != self.userId) {
                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    
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

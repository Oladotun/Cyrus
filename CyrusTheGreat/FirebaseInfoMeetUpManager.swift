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
//    func updateMyImage(image:UIImage)
    func updateOtherUserImage(image:UIImage)
    
}

class FirebaseInfoMeetUpManager: NSObject {
    
    var meetUpPathWay:FIRDatabaseReference!
    var segueToQuestionNode:FIRDatabaseReference!
    var delegate:FirebaseInfoMeetUpManagerDelegate?
    var userId:String!
    var otherUserId:String!
    var questionTime:Bool!
    
    init(meetPath:FIRDatabaseReference,myId:String,otherUserId:String) {
        super.init()
        meetUpPathWay = meetPath
        segueToQuestionNode = meetUpPathWay.child("segueToQuestion")
//            childByAppendingPath("segueToQuestion")
        userId = myId
        self.otherUserId = otherUserId
        observeNextQuestionNode()
//        observeImageUser()
        observeImageOtherUser()
    }
    
//    func observeImageUser() {
//        
//        let userUrl = "https://cyrusthegreat.firebaseio.com/users/\(userId)/image"
//        let userFirebase = FIRDatabase.database().referenceFromURL(userUrl)
//        
//        userFirebase.observeSingleEventOfType(.Value, withBlock: {
//            snapshot in
//            let imageString = snapshot.value as! String
//            let image = imageString.stringToImage()
//            self.delegate?.updateMyImage(image)
//        })
//        
//    }
    
    func observeImageOtherUser() {
        
        let storage = FIRStorage.storage()
        let imageRef = storage.referenceForURL("gs://project-5582715640635114460.appspot.com/\(otherUserId).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let myImage: UIImage! = UIImage(data: data!)
                self.delegate?.updateOtherUserImage(myImage)
                
                
            }
        }
        
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

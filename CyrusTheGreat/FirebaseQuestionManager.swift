//
//  FirebaseQuestionManager.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/12/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase

protocol FirebaseQuestionDelegate {
    func updateQuestionLabel(question:String)
    func chattingDone()
    func meetUpCancelled(canceller:String)
    func segueToMessages()
}

class FirebaseQuestionManager: NSObject,NSCoding {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let questionPrelude:[String] = ["Tell us your favorite memories about","Share a story on why you like" ,"Tell us why you got into"]
    let fieldQuestion = "Tell us why you got into your field of study ?"
    var countQuestions:Int = 0
    var questionPathFirebase:FIRDatabaseReference!
    var segueToMessages:FIRDatabaseReference!
    var meetUpPathWay:FIRDatabaseReference!
    var delegate:FirebaseQuestionDelegate?
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init()

        if let userMeetUpPathway = aDecoder.decodeObjectForKey("cyrusMeetUpPathWay") {
            let meetUpUrl = userMeetUpPathway as! String
            meetUpPathWay = FIRDatabase.database().referenceFromURL(meetUpUrl)
            questionPathFirebase = questionUserFirebase()
            segueToMessages = segueToMessagesFirebase()
            observeQuestionFirebase()
            observeSegueToMessages()
        }
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(meetUpPathWay.URL, forKey: "cyrusMeetUpPathWay")
    }
    
    
    init(meetup:FIRDatabaseReference) {
        super.init()
        meetUpPathWay = meetup
        questionPathFirebase = questionUserFirebase()
        segueToMessages = segueToMessagesFirebase()
        observeQuestionFirebase()
        observeSegueToMessages()
    }
    
    func questionUserFirebase() -> FIRDatabaseReference! {
        return meetUpPathWay.child("question")
    }
    
    func segueToMessagesFirebase() -> FIRDatabaseReference! {
        return meetUpPathWay.child("chatInitiated")
    }
    
    func observeSegueToMessages() {
        segueToMessages.observeEventType(.Value, withBlock: {
            snapshot in
            
            if (snapshot.value is NSNull) {
  
            } else {
                if let value = snapshot.value {
                    let stringValue = value as! String
                    if (self.appDelegate.userIdentifier != stringValue) {
                        self.delegate?.segueToMessages()
                    }
                }
            }
            
            
        })
    
    }
    
    func observeQuestionFirebase() {
        questionPathFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            if (snapshot.childrenCount == 0 ) {
                if let value = snapshot.value as? String {
                    if (!self.appDelegate.iamInitiator) {
                        if (value.contains("_Done_")) {
                            self.delegate?.chattingDone()
                            
                        } else {
                            self.delegate?.updateQuestionLabel(value)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            if (snapshot.childrenCount == 1) {
                for child in snapshot.children {
                    let childSnapshot = snapshot.childSnapshotForPath(child.key!!)
                    
                    if let childValue = childSnapshot.value as? String {
                        
                        if (childValue.contains("_end_chat_")) {
                            let childKey :String = child.key!!
                            self.delegate?.meetUpCancelled(childKey)
                        }
                        
                    }

                    
                }

            }

            
        })
    }

}

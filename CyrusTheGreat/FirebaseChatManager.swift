//
//  FirebaseChatManager.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/12/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

protocol FirebaseChatDelegate {
    func updateChat(chatMsg:String, location:CLLocation)
    var iamSender : Bool! {get set}
    func segueToNextPage()
    func meetUpCancelled(canceller:String)
}

class FirebaseChatManager: NSObject {
    var meetUpPathWay:Firebase! // reference to previous meetup
    var chatMessagePathFirebase:Firebase!
    var chatAcceptPathFirebase:Firebase!
    var userId:String!
    var delegate:FirebaseChatDelegate?
    
    
    init(meetUpPath:Firebase,currUserId:String) {
        super.init()
        self.meetUpPathWay = meetUpPath
        chatMessagePathFirebase = self.chatMessagePath()
        chatAcceptPathFirebase = chatAcceptPath()
        userId = currUserId
        observeChatAcceptPath()
        observeChatMsgPath()
    }
    
    
    
    func chatMessagePath() -> Firebase! {
        guard let _ = meetUpPathWay else {
            NSException(name: "Meet up not set", reason: "Meet up info not set", userInfo: nil).raise()
            return nil
        }
        return meetUpPathWay.childByAppendingPath("chatMsg")
    }
    
    func observeChatMsgPath() {
        guard let _ = self.chatMessagePathFirebase else {
            return
        }
        guard let _ = self.userId else {
            return
        }
        chatMessagePathFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                if (child.key != self.userId) {
                    if let value = childSnapshot.value as? [String:String] {
                        self.delegate?.iamSender = false
                        let destinationLocation = (value["location"])?.stringToCLLocation()
                        let chatMsg = value["message"]
                        
                        self.delegate?.updateChat(chatMsg!,location: destinationLocation!)
                    }
                    
                }
                
            }
            
        })
        
    }
    
    func updateChatMsgPath(msg:String,toSend:[String:String]) {
        
        let info = [msg : toSend]
        chatMessagePathFirebase.setValue(info)
    }
    
    func updateChatAccept(value:String) {
        chatAcceptPathFirebase.setValue(value)
    }
    
    func observeChatAcceptPath() {
        
        var yesCalled = false
        
        chatAcceptPathFirebase.observeEventType(.Value, withBlock: {
            snapshot in
            
            if (!snapshot.value.isEqual(NSNull()) ) {
                
                if(snapshot.value as! String == "Yes") && !yesCalled {
                    
                    self.delegate?.segueToNextPage()
                    yesCalled = true
                    
                }
                
                if(snapshot.value as! String == "No") {
                    
                }
                
                if((snapshot.value as! String).contains("_end_chat_")) {
                    
                    let endWord = snapshot.value as! String
                    
                    let splitEndWord = endWord.componentsSeparatedByString("*_*")
                    // user x ended the chat
//                    print("\(splitEndWord)")
                    self.delegate?.meetUpCancelled(splitEndWord[0])
                    
                    
                }
            }
            
            
            
            
        })
        
    }
    
    func chatAcceptPath() -> Firebase! {
        guard let _ = meetUpPathWay else {
            NSException(name: "Meet up not set in Chat Accept", reason: "Meet up info not set", userInfo: nil).raise()
            return nil
        }
        return meetUpPathWay.childByAppendingPath("chatAccept")
        
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

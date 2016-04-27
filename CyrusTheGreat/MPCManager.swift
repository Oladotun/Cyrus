//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Dotun Opasina on 3/4/16.
//  Copyright (c) 2016 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Firebase


protocol MPCManagerDelegate {
    func foundPeer()
    func lostPeer()
    func invitationWasReceived(fromPeer: String, topic: String)
    func connectedWithPeer(peerID: MCPeerID)
    var findMorePeer: Bool {set get}
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var session: MCSession!
    var peer: MCPeerID!
    var peerTopics: [String]!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    var foundPeers = [MCPeerID]()
    var matchTopic : String!
    var foundPeerMatchScore = [String:Int]()
    var foundPeerMatchTopics = [String:[String]]()
    
    var matchTopics = [String]()
    var invitationHandler: ((Bool, MCSession)->Void) = { status, session in }
    var delegate: MPCManagerDelegate?
    var presentTopic: Bool!
    
    var selectedPeer:MCPeerID!
    
//    var arrayFoundFirebase = [Firebase]()
    
    
    override init() {
        
        super.init()
//        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        peer = MCPeerID(displayName: appDelegate.userIdentifier)
        
    }
    
    
    func initAttributes(topics:[String]) {
       
        
        session = MCSession(peer: peer,securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = self
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc")
        browser.delegate = self
//        print(peerTopics)
        peerTopics = topics
        
//        print(peerTopics)
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcoda-mpc")
        advertiser.delegate = self
        
    }
    
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        
        
        if (context == nil) {
             self.invitationHandler = invitationHandler
            
        } else {
            
            let currInfo =  NSKeyedUnarchiver.unarchiveObjectWithData(context!) as! NSDictionary
            print(currInfo)
            let currPeepTopic = currInfo["topics"] as! [String]
            let currUID = currInfo["chatUid"] as! [String]
            
            // Update current fireUID
           
            print ("I am in advertiser")
//            appendMatchedTopics(currPeepTopic)
            
//            if ((presentTopic) != nil) {
            
                self.invitationHandler = invitationHandler
//                print("Calling Invitation Handler \(invitationHandler)")
//                print("Matched Topics is \(matchTopics)")
            
            print("current name \(peerID.displayName)")
            print("current foundPeerMatch \(foundPeerMatchTopics)")
                matchTopics = currPeepTopic
                
                matchTopic = matchTopics.randomItem()
                delegate?.invitationWasReceived(peerID.displayName, topic: matchTopic)
                
               
               
//                delegate?.findMorePeer = false
                print("currUID \(currUID[0])")
                 appDelegate.fireUID = currUID[0]
                
                self.appDelegate.meetUpFire = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)")
                let meetPath = self.appDelegate.meetUpFire.childByAppendingPath("meetUp")
                meetPath.setValue("Not Set")
            
                let userMatched: NSDictionary = ["matchedTopics" : matchTopics]
            
                self.appDelegate.meetUpFire.updateChildValues(userMatched as [NSObject : AnyObject])
            
                let firstTopic = ["firstTopic" : matchTopic]
            
                self.appDelegate.meetUpFire.updateChildValues(firstTopic as [NSObject : AnyObject])
            
                
                print("Found Pair, setting Peer finding to False")
                
//            }
            
//            else {
//                
//                print("No pair found, setting Peer finding to True")
//                
//                delegate?.findMorePeer = true
//                
//            }
            
        }
        
        
        
    }
    

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error.localizedDescription)
    }
    
//    private func checkMatch(topics: String) -> Bool {
//        
//        let otherArrayTopics = topics.componentsSeparatedByString(",")
//        
//        presentTopic = false
//        for topic in peerTopics {
//            if (otherArrayTopics.contains(topic)) {
//                presentTopic = true
//                break
//            }
//        }
//        return presentTopic
//    }
    
//    func appendMatchedTopics(userTopics: [String]) -> [String]{
//        presentTopic = false
//        for topic in peerTopics {
//            if (userTopics.contains(topic)) {
//                presentTopic = true
//                matchTopics.append(topic)
//            }
//        }
//        
//        return matchTopics
//        
//    }
//    
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        foundPeers.append(peerID)
        print("Found name \(peerID.displayName)")
//        print("Current id display Topics\(info![peerID.displayName])")
        // Find the next user to connect to
        sortFoundUserByScore(peerID)
        delegate?.foundPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("losing peer")
        removePeerInfo(peerID)
        for(index, aPeer) in foundPeers.enumerate() {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        
        
        
        delegate?.lostPeer()
    }
    

    func sortFoundUserByScore(peerDisplay:MCPeerID) {
        let otherUserPathInterests = Firebase(url:  "https://cyrusthegreat.firebaseio.com/users/\(peerDisplay.displayName)/interests")
        
        otherUserPathInterests.observeEventType(.Value, withBlock: {
            snapshot in
            if (snapshot.value != nil) {
                
                if (snapshot.value is NSNull) {
                    
                    print("We have a problem")
                    
                } else {
                    print(snapshot.value)
                    let otherUserInterests = snapshot.value as? [String]
                    self.findMatches(peerDisplay,otherInterests: otherUserInterests!)
                }
                
            }
        })
        
//        let otherUserPathFound = Firebase(url:  "https://cyrusthegreat.firebaseio.com/users/\(peerDisplay.displayName)/available")
        
//        arrayFoundFirebase.append(otherUserPathInterests)
        
//        otherUserPathInterests
        
        
    }
    
    // Find number of matches for a particular user
    
    func findMatches(peerDisplay:MCPeerID,otherInterests:[String]) {
        var count = 0
        var matchTopics = [String]()
        for topic in peerTopics {
            if (otherInterests.contains(topic)) {
                count = count + 1
                matchTopics.append(topic)
                
            }
        }
        var sortedMatchedPeers = [(String,Int)]()
        // We only have 10 users stored at a time
        if (foundPeerMatchScore.count < 10 && matchTopics.count > 0) {
            foundPeerMatchScore[peerDisplay.displayName] = count
            foundPeerMatchTopics[peerDisplay.displayName] = matchTopics
            
            print("found match topics \(foundPeerMatchTopics)")
            
            foundPeers.append(peerDisplay)
        } else {
            
            if (count > sortedMatchedPeers.last!.1) {
                
                foundPeerMatchScore.removeValueForKey(sortedMatchedPeers.last!.0)
                foundPeerMatchTopics.removeValueForKey(sortedMatchedPeers.last!.0)
                
                let removePeer = MCPeerID(displayName: sortedMatchedPeers.last!.0)
                
                for(index, aPeer) in foundPeers.enumerate() {
                    if aPeer == removePeer {
                        foundPeers.removeAtIndex(index)
                        break
                    }
                }
                
//                foundPeers.rem
                
                foundPeerMatchTopics[peerDisplay.displayName] = otherInterests
                foundPeerMatchScore[peerDisplay.displayName] = count
            }
        }
        
         sortedMatchedPeers = foundPeerMatchScore.sort{$0.1 > $1.1}
        
//        selectedPeer = MCPeerID(displayName: sortedMatchedPeers.first!.0)
        selectPeer(sortedMatchedPeers.first!.0)
        
        print("peers to number of matches \n \(sortedMatchedPeers)")
        
    
    }
    
    // Remove a found user match peer information
    func removePeerInfo(peer:MCPeerID) {
        print("removal called")
        foundPeerMatchScore.removeValueForKey(peer.displayName)
        foundPeerMatchTopics.removeValueForKey(peer.displayName)
        
        if (foundPeerMatchScore.count > 0) {
            
            let sortedMatchedPeers = foundPeerMatchScore.sort{$0.1 > $1.1}
            
//            selectedPeer = MCPeerID(displayName: sortedMatchedPeers.first!.0)
            selectPeer(sortedMatchedPeers.first!.0)
            print("found peer")
            
        } else {
            print("setting setting selected peer")
            selectedPeer = nil
        }
        
    }
    
    func selectPeer(peerIDDisplay:String) {
        for found in foundPeers {
            if (found.displayName == peerIDDisplay) {
                selectedPeer = found
            }
        }
    }
    
    
//    func setAvailabilityFalse() {
//        
//        let userAvailable = ["available":"false"]
//        self.appDelegate.userFire.childByAppendingPath("users")
//            .childByAppendingPath(appDelegate.userIdentifier).updateChildValues(userAvailable)
//    }
    
    
    
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(error.localizedDescription)
    }
    
    func setUpMeetUpTruth(){
        print("In set meetup uid is \(self.appDelegate.fireUID)")
        let meetPath = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/meetUp")
        
        print("meetPath in connection Page")
        
        print("\(meetPath.description)")
        
        meetPath.observeEventType(.Value, withBlock: {
            snapshot in
            if (snapshot.value != nil) {
                
                if(snapshot.value as! String == "true") {
                    self.delegate?.connectedWithPeer(MCPeerID(displayName: "_use_firebase_chat_"))
                    
//                    self.setAvailabilityFalse()
                    
                } else {
                    print("timed out")
                    
                    self.delegate?.connectedWithPeer(MCPeerID(displayName: self.peer.displayName))
//                    meetPath.setValue("Timed out")
                }
                
            }
        })
        
    }
    
    
    
    // Connect through firebase with Session
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
        switch state {
        case MCSessionState.Connected:
            print("Connection to session \(session)")
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
             self.appDelegate.matchedTopic = self.matchTopic
            }
//            delegate?.connectedWithPeer(peerID)
//            setAvailabilityFalse()
            delegate?.connectedWithPeer(MCPeerID(displayName: "_use_firebase_chat_"))
            
            
        case MCSessionState.Connecting:
            print("Connecting to session \(session)")
            
        case MCSessionState.NotConnected:
            
            print("Could not connect to session \(session)")
            print("display name \(peerID.displayName)")
            self.setUpMeetUpTruth()
            
            print("\(peer.displayName)")
            
            
        }
    }
    

    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        print("data was sent")
        
        let dictionary: [String: AnyObject] = ["data": data, "fromPeer": peerID]
        NSNotificationCenter.defaultCenter().postNotificationName("receivedMPCDataNotification", object: dictionary)
    }
    
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        let peersArray = NSArray(object: targetPeer)
        
        do {
            try session.sendData(dataToSend, toPeers: peersArray as! [MCPeerID], withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print(error)
            return false
        }
        
        
        return true
    }
    // Unimplemented protocols
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) { }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) { }
    
    func session(session: MCSession!, ddReceiveStream stream: NSInputStream!, wthName streamName: String!, fomPeer peerID: MCPeerID!) {}
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
//    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
//        
//        
//    
//    
//    }

}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}


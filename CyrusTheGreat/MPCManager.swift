//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Dotun Opasina on 3/4/16.
//  Copyright (c) 2016 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity


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
    
    
    var matchTopics = [String]()
    var invitationHandler: ((Bool, MCSession)->Void) = { status, session in }
    var delegate: MPCManagerDelegate?
    var presentTopic: Bool!
    
    
    override init() {
        
        super.init()
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
    }
    
    
    func initAttributes(topics:[String]) {
       
        
        session = MCSession(peer: peer,securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = self
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc")
        browser.delegate = self
//        print(peerTopics)
        peerTopics = topics
        
        print(peerTopics)
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
           
            
            appendMatchedTopics(currPeepTopic)
            
            if ((presentTopic) != nil) {
                
                self.invitationHandler = invitationHandler
//                print("Calling Invitation Handler \(invitationHandler)")
//                print("Matched Topics is \(matchTopics)")
                delegate?.invitationWasReceived(peerID.displayName, topic: matchTopics[0])
               matchTopic = matchTopics[0]
                delegate?.findMorePeer = false
                 appDelegate.fireUID = currUID[0]
                
                
                print("Found Pair, setting Peer finding to False")
                
            } else {
                
                print("No pair found, setting Peer finding to True")
                
                delegate?.findMorePeer = true
                
            }
            
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
    
    func appendMatchedTopics(userTopics: [String]) -> [String]{
        presentTopic = false
        for topic in peerTopics {
            if (userTopics.contains(topic)) {
                presentTopic = true
                matchTopics.append(topic)
            }
        }
        
        return matchTopics
        
    }
    
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        foundPeers.append(peerID)
        print("Found name \(peerID.displayName)")
//        print("Current id display Topics\(info![peerID.displayName])")
        
        delegate?.foundPeer()
    

    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        for(index, aPeer) in foundPeers.enumerate() {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        
        delegate?.lostPeer()
    }
    
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(error.localizedDescription)
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
            delegate?.connectedWithPeer(MCPeerID(displayName: "_use_firebase_chat_"))
            
        case MCSessionState.Connecting:
            print("Connecting to session \(session)")
            
        case MCSessionState.NotConnected:
            
            delegate?.connectedWithPeer(MCPeerID(displayName: "_use_firebase_chat_"))
            print("Could not connect to session \(session)")
            print("display name \(peerID.displayName)")
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

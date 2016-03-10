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
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var session: MCSession!
    
    var peer: MCPeerID!
    var peerTopics: String?
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    
    var invitationHandler: ((Bool, MCSession)->Void) = { status, session in }
    
    var delegate: MPCManagerDelegate?
    
    var peerIDTopics = [String:String]()
    
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
    }
    
    
    func initAttributes(topics:String) {
        
        peerTopics = topics
        
        session = MCSession(peer: peer,securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc")
        //        browser = MCNearbyServiceBrowser(
        browser.delegate = self
        
        peerIDTopics [peer.displayName] = peerTopics
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: peerIDTopics, serviceType: "appcoda-mpc")
        advertiser.delegate = self
        
        
        
    }
    
    
//    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
//        self.invitationHandler = invitationHandler
//        delegate?.invitationWasReceived(peerID.displayName)
//    }
    
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        
//        let peerInfo =  NSKeyedUnarchiver.unarchiveObjectWithData(context!) as! [String]

        self.invitationHandler = invitationHandler
        
        print("Calling Invitation Handler \(invitationHandler)")
//        print("Passed Data \(peerInfo)")
        delegate?.invitationWasReceived(peerID.displayName)
    }
    

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error.localizedDescription)
    }
    
    
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
//        foundPeerTopics.append(peerTopics)
        
        print("Found name \(peerID.displayName)")
        
        print("Current id display Topics\(info![peerID.displayName])")
        
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
    
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
        switch state {
        case MCSessionState.Connected:
            print("Connection to session \(session)")
            delegate?.connectedWithPeer(peerID)
            
        case MCSessionState.Connecting:
            print("Connecting to session \(session)")
            
        case MCSessionState.NotConnected:
            print("Could not connect to session \(session)")
            print("display name \(peerID.displayName)")
            print("\(peer.displayName)")
            
            
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        let dictionary: [String: AnyObject] = ["data": data, "fromPeer": peerID]
        NSNotificationCenter.defaultCenter().postNotificationName("receivedMPCDataNotification", object: dictionary)
    }
    
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        let peersArray = NSArray(object: targetPeer)
//        var error: NSError?
        
        do {
            try session.sendData(dataToSend, toPeers: peersArray as! [MCPeerID], withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print(error)
            return false
        }
        
        
        
//        if !session.sendData(dataToSend, toPeers: peersArray as [AnyObject], withMode: MCSessionSendDataMode.Reliable, error: &error){
//            print(error?.localizedDescription)
//            return false
//        }
        
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

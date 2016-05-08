//
//  HomePageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/1/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Firebase

class HomePageViewController: UIViewController, FirebaseDelegate, CLLocationManagerDelegate { // MPCManagerDelegate
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var currAvailability: UILabel!
    @IBOutlet weak var availSwitch: UISwitch!
    @IBOutlet weak var interestCollected: UILabel!
    @IBOutlet weak var noOfPeer: UILabel!
    var displayView = UIView()
    var interests: [String]!
    var chatInitiator:Bool!
    var alertInvite:UIAlertController!
    var locationManager:CLLocationManager!
    var firebaseManager:FirebaseMeetupManager!
    var userActiveOberverSet = false
    
    
    var findMorePeer = true
    var switchState = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager =  appDelegate.locationManager
        firebaseManager = appDelegate.userFirebaseManager
        
        chatInitiator = false
        availSwitch.setOn(false, animated:true)
        currAvailability.text = "Offline"
        availSwitch.addTarget(self, action: Selector("switched:"), forControlEvents: UIControlEvents.ValueChanged)
//        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.initAttributes(interests)
        noOfPeer.text = ""
        firebaseManager.setUpCurrentUser(appDelegate.userIdentifier)
        firebaseManager.updateUserState("Not Active")
        firebaseManager.fireBaseDelegate = self
        
//        appDelegate.mpcManager.browser.startBrowsingForPeers()
        appDelegate.interests = interests
        
        locationManager.delegate = self
        locationManager.distanceFilter = 20
        locationManager.startUpdatingLocation()
        
        
        
        foundDisplay()
//        appDelegate.userFirebaseManager
        
        
//        let userInfo = Firebase(url: "https://cyrusthegreat.firebaseio.com/users/\(appDelegate.userIdentifier)/first_name")
//        
//        userInfo.observeEventType(.Value, withBlock: {
//            snapshot in
//            
//            if (snapshot.value is NSNull) {
//                print("We have a problem")
//            } else {
//               self.appDelegate.userFirstName =  (snapshot.value as! String)
//            }
//            
//        })
        
//        appDelegate.mpcManager.sortFoundUserByScore(appDelegate.mpcManager.peer)
        
        // Set up alert view
        alertInvite = nil

    }
    
    func switched(switchState: UISwitch) {
        if switchState.on {
            currAvailability.text = "Online"
            firebaseManager.updateUserState("Active")
            firebaseManager.updateActiveUserFirebase()
            self.switchState = true
//            locationManager.startUpdatingLocation()
            
            
            //            self.appDelegate.mpcManager.advertiser.startAdvertisingPeer()
            
        } else {
            currAvailability.text = "Offline"
            firebaseManager.updateUserState("Not Active")
            firebaseManager.removeActiveUser(appDelegate.userIdentifier)
            firebaseManager.userObject.status = "Not Active"
            self.switchState = false
            locationManager.stopUpdatingLocation()
            //            self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        firebaseManager.updateUserLocation(locations.last!)
        print ("user observer is \(userActiveOberverSet)")
        if (switchState == true) {
            firebaseManager.updateActiveUserFirebase()
        }
        if (!userActiveOberverSet) {
            firebaseManager.activateUserObserver()
            userActiveOberverSet = true
            
        }
        
        
    }
    
    
    
    func setUpDisplayView() {
        
       displayView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
       displayView.backgroundColor = UIColor.whiteColor()
       displayView.alpha = 1.0
       displayView.layer.cornerRadius = 10
        
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.grayColor()
        textLabel.text = "Pairing You Up"
        
        displayView.addSubview(activityView)
        displayView.addSubview(textLabel)
        
        view.addSubview(displayView)
        
    }
    
    func receiveInvite(inviter: String) {
        
        alertInvite = UIAlertController(title: "", message: "\(inviter) wants to chat with you", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                // Set up fire UID of user
                
                
            }
            
            
            
            
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
            //            self.appDelegate.mpcManager.invitationHandler(false,MCSession())
            
            // Not connecting and end
//            self.connectedWithPeer(MCPeerID(displayName: " "))
        }
        
        alertInvite.addAction(acceptAction)
        alertInvite.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(self.alertInvite, animated: true, completion: nil)
        }
        

        
        
    }
    
    func foundDisplay() {
        noOfPeer.text = "\(firebaseManager.foundCount)"
        
    }
    
    func declineInvite() {
        print ("decline invite called")
        
    }
    
    func segueToNextPage() {
        print ("going to next page")
    }
    
    func foundPeer() {
        
        noOfPeer.text = "0"
        
    }
    
    func lostPeer() {
        print ("Lost Peer called in home page")
        
        noOfPeer.text = "0"
        
    }
    
//    func connectedWithPeer(peerID: MCPeerID) {
//        print("Connecting from home \(peerID.displayName)")
//        
//        if(peerID.displayName == " ") {
//            
//            print("Could not connect delete cyrus firebase")
//            
//            
//            if (appDelegate.meetUpFire != nil) {
//                appDelegate.meetUpFire.unauth()
//            }
//            
//        } else if (peerID.displayName == "_use_firebase_chat_") {
//            
//            let meetPath = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/meetUp")
//            
//            print("meetPath in connection Page")
//            
//            print("\(meetPath.description)")
////            appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
//            meetPath.observeEventType(.Value, withBlock: {
//                snapshot in
//                if (snapshot.value is NSNull) {
//                    
//                    print("We have a problem")
//                    
//                } else {
//                    NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
//                        
//                        self.performSegueWithIdentifier("idSegueChat", sender: self)
//                        
//                    }
//                }
//            })
//            
//            
//            
////            print("Both users connected")
//            
//        } 
//        
//        
////        else {
////            
////            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
////                
////                self.performSegueWithIdentifier("idSegueChat", sender: self)
////                
////            }
////            
////        }
//        
//       
//    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

    @IBAction func meetUpClicked(sender: AnyObject) {
//         availSwitch.setOn(true, animated:true)
        if (firebaseManager.userObject.status == "Not Active") {
            
            print ("Go online")
            
        } else {
            firebaseManager.meetUpClicked()
        }
        
        
//        print(appDelegate.mpcManager.foundPeers.count)
//        
////        print("Find more peer now set as \(findMorePeer)")
//    
//        // Process all the foundPEERS here
//        
//        if  appDelegate.mpcManager.foundPeers.count > 0 {
//            
//            setUpDisplayView()
//            let selectedPeer = appDelegate.mpcManager.selectedPeer as MCPeerID
//            
//            var contentCreated = [String: [String]]()
//            
//            // Setting up firebase connection
//            self.appDelegate.userFire.authAnonymouslyWithCompletionBlock { error, authData in
//                if error != nil {
//                    // There was an error logging in anonymously
//                    print(error)
//                    
//                } else {
//                    // We are now logged in
//                    
//                    let currData = authData as FAuthData
//                    print(currData.uid)
//                    self.appDelegate.fireUID = currData.uid
//
//                    self.appDelegate.meetUpFire = self.appDelegate.userFire.childByAppendingPath("\(currData.uid)")
//                        
////                        Firebase(url: "https://cyrusthegreat.firebaseio.com/\(currData.uid)")
//                    
////                    self.appDelegate.meetUpFire
//                    
//                    // send data to other user on connection
//                    
//                    contentCreated["topics"] = self.appDelegate.mpcManager.foundPeerMatchTopics[self.appDelegate.mpcManager.selectedPeer.displayName]
//                    contentCreated["chatUid"] = [self.appDelegate.fireUID]
//                    
////                    print("Sent content")
////                    print(contentCreated)
//                    
//                    let dataExample : NSData = NSKeyedArchiver.archivedDataWithRootObject(contentCreated)
//                    self.chatInitiator = true
//                    
//                    print("Going to connect from Meet Up page")
//                    print("selected peer is \(selectedPeer.displayName)")
////                    print(dataExample)
//                    self.appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: self.appDelegate.mpcManager.session, withContext: dataExample, timeout: 20)
//                    
//                }
//            }
//            
//            
//            
//            
//            displayView.removeFromSuperview()
//            
//            
//        }
        
        
        
    }
    
    func invitationWasReceived(fromPeer: String, topic:String ) {
        
        print("Current fireUID in receiver is \(self.appDelegate.fireUID)")
        
       
        
//        print("I got called yeah")
        alertInvite = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you on \(topic)", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                // Set up fire UID of user
                
                self.appDelegate.meetUpFire = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)")
                let meetPath =  Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/meetUp")
                
                
                
                // Set up firebase for questions page
                
//                print("Setting meet up Online")
                
                self.appDelegate.meetUpFire.childByAppendingPath("chatMsg")
                self.appDelegate.meetUpFire.childByAppendingPath("chatAccept").setValue("false")
                
                meetPath.setValue("true")
                
                self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
                
            }
            
            
            
            
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
//            self.appDelegate.mpcManager.invitationHandler(false,MCSession())
            
            // Not connecting and end
//            self.connectedWithPeer(MCPeerID(displayName: " "))
        }
        
        alertInvite.addAction(acceptAction)
        alertInvite.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(self.alertInvite, animated: true, completion: nil)
        }
        
        
        
        
    }
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "idSegueChat" {
            
            let destinationVC = segue.destinationViewController as! ChatViewController
            if (self.chatInitiator == true) {
               destinationVC.initiator = self.chatInitiator
            }
            
            
        }
    }


}

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
import CoreLocation

class HomePageViewController: UIViewController, FirebaseHomeDelegate, CLLocationManagerDelegate {
    
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
    
    var firebaseHomeManager:FirebaseHomeManager!
    var userActiveOberverSet = false
    
    let invitingString = "Inviting"
    let activeString = "Active"
    let notActiveString = "Not Active"
    let yesString = "Yes"
    let noString = "No"
    
    
    var findMorePeer = true
    var switchState = false
    
    var returned = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager =  appDelegate.locationManager
        initialSetup()
        


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        // When we return back from another page
        // Re-initialize
        if (returned) {
            initialSetup()
        }
        
        
    }
    
    func initialSetup() {
        
        availSwitch.setOn(false, animated:true)
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        firebaseHomeManager = FirebaseHomeManager()
        firebaseHomeManager.setUpCurrentUser(appDelegate.userIdentifier)
        firebaseHomeManager.updateUserState(notActiveString)
        firebaseHomeManager.activateUserObserver()
        userActiveOberverSet = false
        currAvailability.text = "Offline"
        locationManager.delegate = self
        locationManager.distanceFilter = 20
        appDelegate.iamInitiator = false
        firebaseHomeManager.delegate = self
        self.switchState = false
        foundDisplay()

        
    }
    
    
    @IBAction func switchChanged(sender: AnyObject) {
        
        let swh : UISwitch = sender as! UISwitch
        if(swh.on){
            swh.setOn(true, animated: true)//But it will already do it.
            currAvailability.text = "Online"
            locationManager.startUpdatingLocation()
            firebaseHomeManager.updateUserState(activeString)
            firebaseHomeManager.updateActiveUserFirebase()
            self.switchState = true
        }
        else{
            swh.setOn(false, animated: true)
            currAvailability.text = "Offline"
            firebaseHomeManager.updateUserState(notActiveString)
            firebaseHomeManager.removeActiveUser(appDelegate.userIdentifier)
            firebaseHomeManager.userObject.status = notActiveString
            self.switchState = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        firebaseHomeManager.updateUserLocation(locations.last!)
        if (switchState == true) {
            firebaseHomeManager.updateActiveUserFirebase()
        }
        
    }
    

    
    func receiveInvite(inviter: String) {
//        print("Invite was received")
        alertInvite = UIAlertController(title: "", message: "\(inviter) wants to chat with you", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                // Set up fire UID of user
                self.firebaseHomeManager.updateChatMeetUp(self.yesString)
                
                
            }

        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.firebaseHomeManager.updateChatMeetUp(self.noString)
  
        }
        
        alertInvite.addAction(acceptAction)
        alertInvite.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(self.alertInvite, animated: true, completion: nil)
        }
        

        
        
    }
    
    func foundDisplay() {
        noOfPeer.text = "\(firebaseHomeManager.allFound.count)"
        
    }
    
    func declineInvite() {
//        print ("decline invite called")
        alertView("Your Invite was declined, Please try again")
        
    }
    
    func segueToNextPage() {
//        print ("going to next page")
        performSegueWithIdentifier("idSegueChat", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

    @IBAction func meetUpClicked(sender: AnyObject) {
        
        if (firebaseHomeManager.userObject.status == notActiveString) {
            
            alertView("Please Go Online")
            
        } else {
            firebaseHomeManager.meetUpClicked()
        }
 
        
    }
    
    @IBAction func unwindHomePageController(segue: UIStoryboardSegue) {
        alertView("Welcome Back Home")
    }
    
    
    func alertView(message:String) {
        
        let alert = UIAlertController(title:"",message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(doneAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "idSegueChat" {
            
            let destinationVC = segue.destinationViewController as! ChatViewController
            self.chatInitiator = !self.firebaseHomeManager.setReceiver
            
            destinationVC.firebaseChatManager = FirebaseChatManager(meetUpPath: self.firebaseHomeManager.meetUpPathWay,currUserId: appDelegate.userIdentifier)
            appDelegate.otherUserIdentifieir = firebaseHomeManager.connectedUserInfo.user.userId
            destinationVC.myName = self.firebaseHomeManager.userObject.firstName
            appDelegate.userObject = self.firebaseHomeManager.userObject
            appDelegate.connectedProfile = self.firebaseHomeManager.connectedUserInfo
            
            firebaseHomeManager.removeMeetHandler()
            firebaseHomeManager.meetUpSet = false
            returned = true
            locationManager.stopUpdatingLocation()
            
            self.switchState = false
            if (self.chatInitiator == true) {
               destinationVC.initiator = self.chatInitiator
               appDelegate.iamInitiator = self.chatInitiator
            }
            
            
        }
    }


}


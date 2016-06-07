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
    @IBOutlet weak var noOfPeer: UILabel!
    
    @IBOutlet weak var userSearching: UIActivityIndicatorView!

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
//            self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
            if (!appDelegate.justMetUpWith.isEmpty) {
//                print("returned from questions page")
                firebaseHomeManager.updateMetUpWith(appDelegate.justMetUpWith)
            }
        }
        
        
    }
    
    
    func initialSetup() {
        userSearching.alpha = 0.0
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
        } else {
            firebaseHomeManager.activateUserObserver()
        }
        
    }
    

    
    @IBAction func logginOut(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("uid")
        currAvailability.text = "Offline"
        firebaseHomeManager.updateUserState(notActiveString)
        firebaseHomeManager.removeActiveUser(appDelegate.userIdentifier)
        firebaseHomeManager.userObject.status = notActiveString
        self.switchState = false
        locationManager.stopUpdatingLocation()
        appDelegate.userFire.unauth()
        self.performSegueWithIdentifier("logOutSegue", sender: self)
        
        print ("log out working")
        
    }
    
    func receiveInvite(invitedUser: UserProfile) {
        alertInvite = UIAlertController(title: "", message: "Hi, You have an invite to catchup from \(invitedUser.user.firstName), who goes to \(invitedUser.user.schoolName) and is in the field of \(invitedUser.user.userField) . \(invitedUser.user.firstName) shares \(invitedUser.userMatchedInterest) as interests with you. We will be discussing about them during your meetup.\n\n Click accept to select a meet up location or decline to cancel", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                // Set up fire UID of user
                self.firebaseHomeManager.updateChatMeetUp(self.yesString)
                
                
            }

        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
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
        firebaseHomeManager.meetUpPathWay.removeValue()
        
    }
    
    func segueToNextPage() {
//        print ("going to next page")
        
        if (!self.firebaseHomeManager.setReceiver) {
            
            let alert = UIAlertController(title:"Invite accepted",message:"Hi, You have been connected with \(firebaseHomeManager.connectedUserInfo.user.firstName), who goes to \(firebaseHomeManager.connectedUserInfo.user.schoolName) and is in the field of \(firebaseHomeManager.connectedUserInfo.user.userField). \(firebaseHomeManager.connectedUserInfo.user.firstName) shares \(firebaseHomeManager.connectedUserInfo.userMatchedInterest) as interests with you. We will be discussing about them during your meetup.\n\n Click okay to select a meet up location" , preferredStyle: UIAlertControllerStyle.Alert)
            
            let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                
                 self.performSegueWithIdentifier("idSegueChat", sender: self)
            }
            
            alert.addAction(doneAction)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
        } else {
           self.performSegueWithIdentifier("idSegueChat", sender: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

    @IBAction func meetUpClicked(sender: AnyObject) {
        if (firebaseHomeManager.userObject.status == notActiveString) {
            
            alertView("Please Go Online")
            
        } else {
            
            if (firebaseHomeManager.allFound.count < 1) {
                alertView("No User Online, Pls try again later")
            } else {
                userSearching.alpha = 1.0
                userSearching.startAnimating()
                firebaseHomeManager.meetUpClicked()
            }
            
        }
 
        
    }
    
    @IBAction func unwindHomePageController(segue: UIStoryboardSegue) {
//        alertView("Welcome Back Home")
        
        
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
            firebaseHomeManager.removeActiveUser(appDelegate.userIdentifier)
            firebaseHomeManager.removeMeetHandler()
            firebaseHomeManager.meetUpSet = false
            returned = true
            locationManager.stopUpdatingLocation()
            appDelegate.justMetUpWith = ""
            
            self.switchState = false
            if (self.chatInitiator == true) {
               destinationVC.initiator = self.chatInitiator
               appDelegate.iamInitiator = self.chatInitiator
            }
            
            
        }
    
    }


}


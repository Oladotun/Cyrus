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

class HomePageViewController: UIViewController, FirebaseHomeDelegate, CLLocationManagerDelegate { // MPCManagerDelegate
    
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
    var firebaseManager:FirebaseManager!
    var userActiveOberverSet = false
    
    
    var findMorePeer = true
    var switchState = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager =  appDelegate.locationManager
        firebaseManager = appDelegate.userFirebaseManager
        
        availSwitch.setOn(false, animated:true)
        currAvailability.text = "Offline"
        availSwitch.addTarget(self, action: Selector("switched:"), forControlEvents: UIControlEvents.ValueChanged)
      
        firebaseManager.setUpCurrentUser(appDelegate.userIdentifier)
        firebaseManager.updateUserState("Not Active")
        firebaseManager.fireBaseDelegate = self
        
        locationManager.delegate = self
        locationManager.distanceFilter = 20
        locationManager.startUpdatingLocation()
        
        
        
        foundDisplay()
        alertInvite = nil

    }
    
    func switched(switchState: UISwitch) {
        if switchState.on {
            currAvailability.text = "Online"
            firebaseManager.updateUserState("Active")
            firebaseManager.updateActiveUserFirebase()
            self.switchState = true
            
        } else {
            currAvailability.text = "Offline"
            firebaseManager.updateUserState("Not Active")
            firebaseManager.removeActiveUser(appDelegate.userIdentifier)
            firebaseManager.userObject.status = "Not Active"
            self.switchState = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("user location update called")
        firebaseManager.updateUserLocation(locations.last!)
        print ("user observer is \(userActiveOberverSet)")
        if (switchState == true) {
            firebaseManager.updateActiveUserFirebase()
        }
        if (!userActiveOberverSet) {
            print("setting users up")
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
        print("Invite was received")
        alertInvite = UIAlertController(title: "", message: "\(inviter) wants to chat with you", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                // Set up fire UID of user
                self.firebaseManager.updateChatMeetUp("Yes")
                
                
            }

        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.firebaseManager.updateChatMeetUp("No")
  
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
        performSegueWithIdentifier("idSegueChat", sender: self)
    }
    
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
 
        
    }
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "idSegueChat" {
            
            let destinationVC = segue.destinationViewController as! ChatViewController
            self.chatInitiator = !self.firebaseManager.setReceiver
            if (self.chatInitiator == true) {
               destinationVC.initiator = self.chatInitiator
            }
            
            
        }
    }


}

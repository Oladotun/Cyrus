//
//  MeetUpPageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/16/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AudioToolbox
import CoreBluetooth
import Firebase

class MeetUpPageViewController: UIViewController, MapTrackerDelegate,FirebaseInfoMeetUpManagerDelegate { // ,CBCentralManagerDelegate , UITextFieldDelegate

    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var destination:String!


    @IBOutlet weak var timeToMeetUpAlert: UILabel!
    @IBOutlet weak var meetupTime: UILabel!
    @IBOutlet weak var meetupDesc: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    
    var otherUserID:String!
//    var firebaseManager:FirebaseManager!
    var firebaseMeetUpManager: FirebaseInfoMeetUpManager!
//    var segueToQuestionNode : Firebase!
//    var questionTime:Bool!
    var time:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        meetupDesc.text = "MeetUp Destination is at \(destination)"
        meetupTime.text = "Planned meetup time is \(time)"
        timeToMeetUpAlert.text = ""
        yesButton.alpha = 1.0
        firebaseMeetUpManager.questionTime = false
        firebaseMeetUpManager.delegate = self


    }
    
    func segueToNext() {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            // Set up fire UID of user
            self.performSegueWithIdentifier("toQuestion", sender: self)


        }
        
    }
    
    func alertOtherUserArrival() {
        
        self.timeToMeetUpAlert.text = "Other user has arrived location"
        
    }
    
    func arrived() {
        yesButton.alpha = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO disconnect session after
    @IBAction func yesMeetup(sender: AnyObject) {
        
        firebaseMeetUpManager.questionTime = true
        let messageDictionary: [String: Bool] = [appDelegate.userIdentifier: true]
        firebaseMeetUpManager.segueToQuestionNode.updateChildValues(messageDictionary)
        
    
    }
    
    
    
  
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "toQuestion") {
        
            let destVC = segue.destinationViewController as! UINavigationController
            let questVC = destVC.topViewController as! QuestionsViewController
            questVC.firebaseQuestionManager = FirebaseQuestionManager(meetup: firebaseMeetUpManager.meetUpPathWay)
        }
        
        
    }


}

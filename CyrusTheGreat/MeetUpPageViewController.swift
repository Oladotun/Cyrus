//
//  MeetUpPageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/16/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit


class MeetUpPageViewController: UIViewController, MapTrackerDelegate,FirebaseInfoMeetUpManagerDelegate { // ,CBCentralManagerDelegate , UITextFieldDelegate

    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var otherImageLoader: UIActivityIndicatorView!
    @IBOutlet weak var myImageLoader: UIActivityIndicatorView!
    var destination:String!

    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var myNameInfo: UILabel!

    @IBOutlet weak var otherUserImage: UIImageView!
    @IBOutlet weak var otherUserInfo: UILabel!
    
    @IBOutlet weak var timeToMeetUpAlert: UILabel!
    @IBOutlet weak var meetupTime: UILabel!
    @IBOutlet weak var meetupDesc: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var arrivalQuestions: UILabel!
    
    var otherUserID:String!
//    var firebaseManager:FirebaseManager!
    var firebaseMeetUpManager: FirebaseInfoMeetUpManager!
//    var segueToQuestionNode : Firebase!
//    var questionTime:Bool!
    var time:String!
    var timer:NSTimer!
    
    init(time:String,destination:String,firebase:FirebaseInfoMeetUpManager) {
        super.init(nibName: nil, bundle: nil)
        self.time = time
        self.destination = destination
        self.firebaseMeetUpManager = firebase
        restorationIdentifier = "MeetUpPageViewControllerId"
        restorationClass = MeetUpPageViewController.self
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)!
        restorationIdentifier = "MeetUpPageViewControllerId"
        restorationClass = MeetUpPageViewController.self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        restorationIdentifier = "MeetUpPageViewControllerId"
//        restorationClass = MeetUpPageViewController.self
        myImageLoader.startAnimating()
        otherImageLoader.startAnimating()
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(MeetUpPageViewController.updateMyImage), userInfo: nil, repeats: true)


    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        meetupDesc.text = "MeetUp Destination is at \(destination)"
        meetupTime.text = "Planned meetup time is \(time)"
        timeToMeetUpAlert.text = ""
        self.timeToMeetUpAlert.textColor = UIColor.redColor()
        yesButton.alpha = 1.0
//        firebaseMeetUpManager.questionTime = false
        firebaseMeetUpManager.delegate = self
        myNameInfo.text = appDelegate.userObject.firstName
        otherUserInfo.text = appDelegate.connectedProfile.user.firstName
    }
    func updateMyImage() {
        if let image = appDelegate.myImage {
            myImage.contentMode = .ScaleAspectFit
            myImage.image = image
            myImageLoader.stopAnimating()
            myImageLoader.alpha = 0.0
            timer.invalidate()
            
        }
        
    }
    
    func updateOtherUserImage(image:UIImage) {
        otherUserImage.contentMode = .ScaleAspectFit
        otherUserImage.image = image
        otherImageLoader.stopAnimating()
        otherImageLoader.alpha = 0.0
    }
    
    
    // Restore Info
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        //1
        
        if let meetTime = time {
            coder.encodeObject(meetTime, forKey: "CyrusChatTime")
        }
        if let destiny = destination {
            coder.encodeObject(destiny, forKey: "CyrusDestination")
        }
       
        
        if let firebase = firebaseMeetUpManager {
            coder.encodeObject(firebase, forKey: "firebaseMeetUpInfo")
        }

        //2
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        
        if let ct = coder.decodeObjectForKey("CyrusChatTime") {
            time = ct as! String
        }
        if let dest = coder.decodeObjectForKey("CyrusDestination") {
            destination = dest as! String
        }
        
        if let firebaseInfo = coder.decodeObjectForKey("firebaseMeetUpInfo") {
            firebaseMeetUpManager = firebaseInfo as! FirebaseInfoMeetUpManager
        }
        super.decodeRestorableStateWithCoder(coder)
    }
    
    override func applicationFinishedRestoringState() {
        // Final configuration goes here.
        // Load images, reload data, e. t. c.
        guard let _ = firebaseMeetUpManager else { return }
        print("in meet up info restored")
        
    }
    
    static func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        var time = ""
        var destination = ""
        var firebaseMeetUpManager:FirebaseInfoMeetUpManager
        if let ct = coder.decodeObjectForKey("CyrusChatTime") {
            time = ct as! String
        }
        if let dest = coder.decodeObjectForKey("CyrusDestination") {
            destination = dest as! String
        }
        
//        if let firebaseInfo = coder.decodeObjectForKey("firebaseMeetUpInfo") {
//            firebaseMeetUpManager = firebaseInfo as! FirebaseInfoMeetUpManager
//        }
        print("\(time) loaded")
        firebaseMeetUpManager = coder.decodeObjectForKey("firebaseMeetUpInfo") as! FirebaseInfoMeetUpManager
        let vc = MeetUpPageViewController(time: time,destination: destination,firebase: firebaseMeetUpManager)
        return vc
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
        yesButton.alpha = 0.0
        arrivalQuestions.text = "Notifying, \(appDelegate.connectedProfile.user.firstName) of your arrrival"
        arrivalQuestions.textColor = UIColor.redColor()
        
    
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

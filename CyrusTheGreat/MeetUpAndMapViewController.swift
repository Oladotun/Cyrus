//
//  MeetUpAndMapViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 4/20/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import CoreLocation


class MeetUpAndMapViewController: UIViewController {

    @IBOutlet weak var meetUpInfoContainer: UIView!
    @IBOutlet weak var locationContainer: UIView!
    var time:String!
    var destination: String!
    var placeAddress:String!
    var destinationLocation:CLLocation!
    var meetUpPage:MeetUpPageViewController!
    var mapPage: MapTrackViewController!
    
    var firebaseMapManager:FirebaseMapManager!
    var firebaseMeetupInfoManager:FirebaseInfoMeetUpManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "MeetUpAndMapViewControllerId"
        restorationClass = MeetUpAndMapViewController.self
        self.meetUpInfoContainer.alpha = 1
        self.locationContainer.alpha = 0
        print("Called me again")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if let placement = placeAddress {
            coder.encodeObject(placement, forKey: "CyrusPlacedAddress")
        }
        
        if let locateDestiny = destinationLocation {
            coder.encodeObject(locateDestiny, forKey: "CyrusDestinyLocation")
        }
        
        if let firebase = firebaseMeetupInfoManager {
            coder.encodeObject(firebase, forKey: "firebaseMeetUpInfo")
        }
        
        if let firebaseMap = firebaseMapManager {
            coder.encodeObject(firebaseMap, forKey: "firebaseMapManager")
        }
        

        if let vc = mapPage {
            coder.encodeObject(vc, forKey: "mapPageInfo")
        }
        
        if let vc = meetUpPage {
            coder.encodeObject(vc, forKey: "meetUpPageViewController")
        }
        
//        self.viewContr
        //2
        super.encodeRestorableStateWithCoder(coder)
//        meetUpInfoContainer.
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        
        if let ct = coder.decodeObjectForKey("CyrusChatTime") {
            time = ct as! String
        }
        if let dest = coder.decodeObjectForKey("CyrusDestination") {
            destination = dest as! String
        }
        if let place = coder.decodeObjectForKey("CyrusPlacedAddress") {
            placeAddress = place as! String
            
        }
        if let destLC = coder.decodeObjectForKey("CyrusDestinyLocation") {
            destinationLocation = destLC as! CLLocation
        }
        if let firebaseInfo = coder.decodeObjectForKey("firebaseMeetUpInfo") {
            firebaseMeetupInfoManager = firebaseInfo as! FirebaseInfoMeetUpManager
            
        }
        if let firebaseMap = coder.decodeObjectForKey("firebaseMapManager") {
            firebaseMapManager = firebaseMap as! FirebaseMapManager
        }
        
        super.decodeRestorableStateWithCoder(coder)
    }
    
    override func applicationFinishedRestoringState() {
        // Final configuration goes here.
        // Load images, reload data, e. t. c.
        guard let _ = firebaseMeetupInfoManager else { print("info error nil");return }
        guard let _ = firebaseMapManager else {print("bae map manager error"); return}

    }
    
    static func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        let vc = MeetUpAndMapViewController()
        return vc
    }
    
    
    

    @IBAction func showComponent(sender: UISegmentedControl) {
        
        if (sender.selectedSegmentIndex == 0) {
            UIView.animateWithDuration(0.5, animations: {
                self.meetUpInfoContainer.alpha = 1
                self.locationContainer.alpha = 0
            })
        } else {
            
            UIView.animateWithDuration(0.5, animations: {
                self.meetUpInfoContainer.alpha = 0
                self.locationContainer.alpha = 1
            })
            
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if (segue.identifier == "meetWearingSegue") {
//            print("Called wearing segue")
            
                let childViewController = segue.destinationViewController as! MeetUpPageViewController
                childViewController.time = time
                childViewController.destination = destination
                childViewController.firebaseMeetUpManager = firebaseMeetupInfoManager
                
                meetUpPage = childViewController // use this map controller as delegate for map track
            
            
            
        }
        
        if (segue.identifier == "mapSegue") {
//            print("Called map segue")
            
                let childViewController = segue.destinationViewController as! MapTrackViewController
                childViewController.addressString = placeAddress
                childViewController.destinationLocation = destinationLocation
                childViewController.mapProtocol = meetUpPage
                childViewController.firebaseMapManager = firebaseMapManager
                mapPage = childViewController
          
            
            
//            meetUpInfoContainer
            
        }
    }
    

}

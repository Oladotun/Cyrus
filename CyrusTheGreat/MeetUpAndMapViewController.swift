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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.meetUpInfoContainer.alpha = 1
        self.locationContainer.alpha = 0

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func showComponent(sender: UISegmentedControl) {
        
        if (sender.selectedSegmentIndex == 0) {
            UIView.animateWithDuration(0.5, animations: {
                self.meetUpInfoContainer.alpha = 1
                self.locationContainer.alpha = 0
//                self.containerViewB.alpha = 0
            })
        } else {
            
            UIView.animateWithDuration(0.5, animations: {
                self.meetUpInfoContainer.alpha = 0
                self.locationContainer.alpha = 1
                //                self.containerViewB.alpha = 0
            })
            
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if (segue.identifier == "meetWearingSegue") {
            print("Called wearing segue")
            let childViewController = segue.destinationViewController as! MeetUpPageViewController
            childViewController.time = time
            childViewController.destination = destination
            meetUpPage = childViewController
            
        }
        
        if (segue.identifier == "mapSegue") {
            print("Called map segue")
            let childViewController = segue.destinationViewController as! MapTrackViewController
            childViewController.addressString = placeAddress
            childViewController.destinationLocation = destinationLocation
            childViewController.mapProtocol = meetUpPage
            
//            meetUpInfoContainer
            
        }
    }
    

}

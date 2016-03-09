//
//  HomePageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/1/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HomePageViewController: UIViewController,  MPCManagerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var currAvailability: UILabel!
    @IBOutlet weak var availSwitch: UISwitch!
    
    @IBOutlet weak var interestCollected: UILabel!
    
    var displayView = UIView()
    var interests: [String]!
    
    @IBOutlet weak var noOfPeer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        availSwitch.setOn(false, animated:true)
        currAvailability.text = "Offline"
        availSwitch.addTarget(self, action: Selector("switched:"), forControlEvents: UIControlEvents.ValueChanged)
        appDelegate.mpcManager.delegate = self
        noOfPeer.text = ""
        appDelegate.mpcManager.browser.startBrowsingForPeers()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "invitationWasReceived:", name: "testInvitation", object: nil)
        
        
//        if interests.count > 0 {
//            
//            self.interestCollected.text = (interests.joinWithSeparator(","))
//            
//        }

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
    
    func foundPeer() {
        
        noOfPeer.text = "\(appDelegate.mpcManager.foundPeers.count)"
        
    }
    
    func lostPeer() {
        
        noOfPeer.text = "\(appDelegate.mpcManager.foundPeers.count)"
        
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        print("Connecting from home \(peerID.displayName)")
        
//        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
//            
//            self.performSegueWithIdentifier("idSegueChat", sender: self)
//            
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switched(switchState: UISwitch) {
        if switchState.on {
            currAvailability.text = "Online"
            self.appDelegate.mpcManager.advertiser.startAdvertisingPeer()
            
        } else {
            currAvailability.text = "Offline"
            self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        }
    }
    

    @IBAction func meetUpClicked(sender: AnyObject) {
         availSwitch.setOn(true, animated:true)
        
        print(appDelegate.mpcManager.foundPeers.count)
        
        
        
        if  appDelegate.mpcManager.foundPeers.count > 0 {
            
            setUpDisplayView()
            let selectedPeer = appDelegate.mpcManager.foundPeers[0] as MCPeerID
            print("Going to connect from Meet Up page")
            appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
            displayView.removeFromSuperview()
            
            
        }
        
//        let load = UIActivityViewController(activityItems: [nil], applicationActivities: nil)
        
        
        
    }
    
    func invitationWasReceived(fromPeer: String) {
        
        print("I got called yeah")
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
            self.appDelegate.mpcManager.invitationHandler(false,MCSession())
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
        
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

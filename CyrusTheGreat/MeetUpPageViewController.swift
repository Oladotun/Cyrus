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

class MeetUpPageViewController: UIViewController, UITextFieldDelegate,CBCentralManagerDelegate {
    
    var pmanager: CBCentralManager!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var messagesArray: [Dictionary<String,String>] = []
    var otherPersonName:String!
    var destination:String!
    var time: String!
    var timerInvalidate:Bool!
    var sessionDisconnected:Bool!
    
    var timer = NSTimer() //make a timer variable, but do do anything yet
    let timeInterval:NSTimeInterval = 10.0
    

    @IBOutlet weak var timeToMeetUpAlert: UILabel!
    @IBOutlet weak var meetupTime: UILabel!
    @IBOutlet weak var meetupDesc: UILabel!
    @IBOutlet weak var personDesc: UILabel!
    @IBOutlet weak var personClothing: UITextField!
    
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
        personClothing.delegate = self
        meetupDesc.text = "MeetUp Destination is at \(destination)"
        meetupTime.text = "Planned meetup time is \(time)"
        timeToMeetUpAlert.text = ""
        yesButton.alpha = 0.0
        timerInvalidate = false
        sessionDisconnected = false
        
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
            target: self,
            selector: "alertPhone:",
            userInfo: "finished",
            repeats: true)
//        alertPhone()

        // Do any additional setup after loading the view.
    }
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! NSDictionary
        
        if let message = dataDictionary["message"] as? String {
            messagesArray = []
            
            if message != "_end_chat_" {
                // Create a new dictionary and set the sender and the received message to it.
                
//                print("Handle Receiving data")
                
                // Reload the tableview data and scroll to the bottom using the main thread.
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.personDesc.text = "\(fromPeer.displayName) is wearing \(message)"
                    self.otherPersonName = fromPeer.displayName
                
                })
                
                
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func yesMeetup(sender: AnyObject) {
        timerInvalidate = true
        pmanager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        appDelegate.mpcManager.session.disconnect()
        
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        appDelegate.mpcManager.browser.startBrowsingForPeers()
    }
    

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if (textField.text == "") {
            print("Enter Destination")
        } else {
//            print("text field isnt empty")

            let toSendMessage = textField.text
            let messageDictionary: [String: String] = ["message": toSendMessage!]
            
            if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] ) {
                
                // Hide button after sent
                
                textField.enabled = false
//                textField.userInteractionEnabled = false
                
            } else {
                print("Could not send data")
            }
            

            
        }
        
        return true
    }
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("\(peripheral.name)")
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("checking state")
        switch (central.state) {
        case .PoweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            
        case .PoweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            //            blueToothReady = true;
            
        case .Resetting:
            print("CoreBluetooth BLE hardware is resetting")
            
        case .Unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            
        case .Unknown:
            print("CoreBluetooth BLE state is unknown");
            
        case .Unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform");
            
        }
        //        if blueToothReady {
        //            discoverDevices()
        //        }
    }
    
    

    
    
    func alertPhone(timer:NSTimer) {
        
//        let timeFormater = NSDateFormatter
        let inFormatter = NSDateFormatter()
        inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        inFormatter.dateFormat = "hh:mm a"
        
        
        let outFormatter = NSDateFormatter()
        outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        outFormatter.dateFormat = "hh:mm a"
        
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let date = inFormatter.dateFromString(time)!
        let meetUpTime = inFormatter.stringFromDate(date)
        
        let minusFiveMin = date.dateByAddingTimeInterval(-5 * 60)
        let minusFiveMinString = outFormatter.stringFromDate(minusFiveMin)
        
        
        
        let currentTime = dateFormatter.stringFromDate(todaysDate)
        
        
        if (!sessionDisconnected) {
            sessionDisconnected = true
            
            if (!personClothing.enabled && otherPersonName != nil) {
                appDelegate.mpcManager.session.disconnect()
            }
        }
        
        if (timerInvalidate == true) {
            timer.invalidate()
        }else if minusFiveMinString == currentTime {
            timeToMeetUpAlert.text = "Are you on your way to meet up with \(self.otherPersonName) "
            yesButton.alpha = 1.0
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else if meetUpTime == currentTime {
            timeToMeetUpAlert.text = "Meet Up now with \(self.otherPersonName)"
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            yesButton.alpha = 1.0
//            appDelegate.mpcManager.session.disconnect()
        } else {
            print("false")
        }
        
//        time
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
//
//  MeetUpPageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/16/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MeetUpPageViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var messagesArray: [Dictionary<String,String>] = []
    var destination:String!
    var time: String!

    @IBOutlet weak var personDesc: UILabel!
    @IBOutlet weak var personClothing: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)

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
                let messageDictionary: [String: String] = ["sender": fromPeer.displayName, "message": message]
                
                messagesArray.append(messageDictionary)
                
                personDesc.text = "\(fromPeer.displayName) is wearing \(message)"
                
                print("Receiving data")
                
                // Reload the tableview data and scroll to the bottom using the main thread.
//                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
////                    self.updateTableView()
//                
//                })
                
                
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    @IBAction func wearingDesc(sender: AnyObject) {
//        
//        let toSendMessage = ""
//        let messageDictionary: [String: String] = ["message": toSendMessage]
//        
//        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] ) {
//            
////            let dictionary: [String:String] = ["sender": "self","message": toSendMessage]
////            messagesArray.append(dictionary)
////            txtChat.text = ""
//            
////            self.updateTableView()
//            // Hide button after sent
////            sendButton.alpha = 0.0
//            
//        } else {
//            print("Could not send data")
//        }
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if (textField.text == "") {
            print("Enter Destination")
        } else {
            
            let toSendMessage = textField.text
            let messageDictionary: [String: String] = ["message": toSendMessage!]
            
            if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] ) {
                
                //            let dictionary: [String:String] = ["sender": "self","message": toSendMessage]
                //            messagesArray.append(dictionary)
                //            txtChat.text = ""
                
                //            self.updateTableView()
                // Hide button after sent
                
                textField.enabled = false
                textField.userInteractionEnabled = false
                //            sendButton.alpha = 0.0
                
            } else {
                print("Could not send data")
            }
            

            
        }
        
        return true
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

//
//  ChatViewController.swift
//  MPCRevisited
//
//  Created by Gabriel Theodoropoulos on 11/1/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ChatViewDelegate {

    @IBOutlet weak var txtChat: UITextField!
    @IBOutlet weak var meetTimePicker: UIDatePicker!
    @IBOutlet weak var tblChat: UITableView!
    var messagesArray: [Dictionary<String,String>] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var chatMessage: String!
    var chatDate: String!
    
    var iamSender:Bool!
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblChat.delegate = self
        tblChat.dataSource = self
        
        // Dynamic sizing of chat box
        tblChat.estimatedRowHeight = 60.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        txtChat.delegate = self
        updateChatDate()
        sendButton.alpha = 0.0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moveToNext:", name: "chatYesClicked", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func meetTimeAction(sender: AnyObject) {
       updateChatDate()
        
    }
    
    func updateChatDate() {
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        chatDate = timeFormatter.stringFromDate(meetTimePicker.date)
        print( timeFormatter.stringFromDate(meetTimePicker.date))
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: IBAction method implementation
    
    @IBAction func endChat(sender: AnyObject) {
        
        let messageDictionary: [String:String] = ["message":"_end_chat_"]
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] ){
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.appDelegate.mpcManager.session.disconnect()
            })
        }
        
    }
    

    
    func yesTapped() {
        print("Accepted")
        
        // Close chat and go to another page with time and meet up location
        // If user opens app, it should go to a page with time and meet up location info
        // When the time for meet up, we ask the user if there have met up with this user
        
        
        
        
        
        let toSendMessage = "segueToNext"
        
        let messageDictionary: [String: String] = ["message": toSendMessage]
        
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] ) {
            
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                
                self.performSegueWithIdentifier("yesSegue", sender: self)
                
            }
            
            
        } else {
            print("Could not send data")
        }
        
        
        
    }
    
    func noTapped() {
        print("Declined")
        
        // when declined, we ask the user to propose time
        
    }
    
    // Method for handling received data 
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        
        print("Notifier called")
        // Get the dictionary containing the data and the source peer from the notification.
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
                
                
                if message == "segueToNext" {
                    NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                        
                        self.performSegueWithIdentifier("yesSegue", sender: self)
                        
                    }
                    
                } else {
                    
                    let messageDictionary: [String: String] = ["sender": fromPeer.displayName, "message": message]
                    
                    messagesArray.append(messageDictionary)
                    
                    print("Receiving data")
                    
                    // Reload the tableview data and scroll to the bottom using the main thread.
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    
                        self.iamSender = false
                        
                        self.updateTableView()
                    })
                    
                }
                
                
                
                
                
                
            } else {
                
                // In this case an "_end_chat_" message was received.
                // Show an alert view to the user.
                
                let alert = UIAlertController(title:"",message: "\(fromPeer.displayName) ended this chat", preferredStyle: UIAlertControllerStyle.Alert)
                
                let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    self.appDelegate.mpcManager.session.disconnect()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                alert.addAction(doneAction)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            }
        
            
            
        }
   
    }
    
    
    // Chat method
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        if textField == txtChat {
            
            if txtChat.text == "" {
                print("Cant accept empty input")
            } else {
                chatMessage = txtChat.text
                sendButton.alpha = 1.0
            }
           
        }
        
        return true
    }
    
    
    @IBAction func sendButton(sender: AnyObject) {
        
            print(chatDate)
            print(chatMessage)
        
            let toSendMessage = chatMessage + "\n" + chatDate
    
            let messageDictionary: [String: String] = ["message": toSendMessage]
    
            if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] ) {
    
                let dictionary: [String:String] = ["sender": "self","message": toSendMessage]
                messagesArray.append(dictionary)
                txtChat.text = ""
    
                self.updateTableView()
                // Hide button after sent
                sendButton.alpha = 0.0
                iamSender = true
    
            } else {
                print("Could not send data")
            }
        
    }
    
    
    func updateTableView() {
        
        self.tblChat.reloadData()
        if self.tblChat.contentSize.height > self.tblChat.frame.size.height {
            tblChat.scrollToRowAtIndexPath(NSIndexPath(forRow: messagesArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }
    
    
    // MARK: UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagesArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tblChat.dequeueReusableCellWithIdentifier("idCell")! as! ChatViewCell
        cell.chatMessage.text = messagesArray[indexPath.row]["message"]
        
        if(indexPath.row == messagesArray.count - 1) {
            
//            print(iamSender!)
            if (iamSender! == true) {
                cell.yesButton.alpha = 0.0
                cell.noButton.alpha = 0.0
            } else {
                cell.yesButton.alpha = 1.0
                cell.noButton.alpha = 1.0
            }
            
        } else {
            cell.yesButton.alpha = 0.0
            cell.noButton.alpha = 0.0
        }
        cell.chatViewProtocol = self
        messagesArray = []
        
        return cell
    }
    
    
}

//
//  ChatViewController.swift
//  MPCRevisited
//
//  Created by Gabriel Theodoropoulos on 11/1/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Firebase
class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ChatViewDelegate {

    @IBOutlet weak var txtChat: UITextField!
    @IBOutlet weak var meetTimePicker: UIDatePicker!
    @IBOutlet weak var tblChat: UITableView!
//    var messagesArray: [Dictionary<String,String>] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var alertEndChat:UIAlertController!
    
    var messagesArray: [String] = []
    
    @IBOutlet weak var warningLabel: UILabel!
    var chatMessage: String!
    var chatDate: String!
    var messageCount: Int!
    var initiator = false
    var observer:  NSObjectProtocol!
    
//    var otherUserUID:String!
    
    var iamSender:Bool!
    var chatMsgPath: Firebase!
    var chatAcceptPath: Firebase!
    
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("initiator is \(initiator)")
        print("We are setting up to initiate")
        
       chatMsgPath = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/chatMsg")
       chatAcceptPath = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/chatAccept")
        chatAcceptPath.setValue("no")
        
        chatAcceptPath.observeEventType(.Value, withBlock: {
            snapshot in
            
            if(snapshot.value as! String == "yes") {
                
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                    
                    self.performSegueWithIdentifier("yesSegue", sender: self)
                    
                }
                
            }
            
            if((snapshot.value as! String).contains("_end_chat_")) {
                
                let endWord = snapshot.value as! String
                
                let splitEndWord = endWord.componentsSeparatedByString("*_*")
                
                let alert = UIAlertController(title:"",message: "\(splitEndWord[0]) Ended the chat", preferredStyle: UIAlertControllerStyle.Alert)
                
                let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                alert.addAction(doneAction)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            }
            
            
        })
        
        
        chatMsgPath.observeEventType(.Value, withBlock: {
            snapshot in
            if let val = snapshot.value as? String {
                
                let sendMsg = val.componentsSeparatedByString("_value_")
                
                if (sendMsg.count > 0) {
                    if(sendMsg[0] == self.appDelegate.userIdentifier ){
                        self.iamSender = true
                        
                    } else {
                        self.iamSender = false
                    }
                    
                    print("time and date is \(sendMsg[1])")
                    self.messagesArray.append(sendMsg[1])
                    
                    self.updateTableView()
                }
                
            } else {
                print("Message path not set") 
            }
            
            
        })
        
        
        // Do any additional setup after loading the view.
        tblChat.delegate = self
        tblChat.dataSource = self
        
        // Dynamic sizing of chat box
        tblChat.estimatedRowHeight = 60.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        txtChat.delegate = self
        updateChatDate()
        sendButton.alpha = 0.0
        messageCount = 0
        warningLabel.text = ""
        warningLabel.textColor = UIColor.redColor()
        
        
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
        print( "Time for chat meet \(chatDate)")
        
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
        
//        let messageDictionary: [String:String] = ["message":"_end_chat_"]
//        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] ){
//            self.dismissViewControllerAnimated(true, completion: { () -> Void in
//                self.appDelegate.mpcManager.session.disconnect()
//            })
//        }
       
        
        alertEndChat = UIAlertController(title: "", message: "Are you sure you want to end chat and meet up", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                        // Set up fire UID of user
                         self.chatAcceptPath.setValue("\(self.appDelegate.userIdentifier)*_*_end_chat_")
                }
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
            //            self.appDelegate.mpcManager.invitationHandler(false,MCSession())
            
            // Not connecting and end
            
        }
        
        self.alertEndChat.addAction(acceptAction)
        self.alertEndChat.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(self.alertEndChat, animated: true, completion: nil)
        }
        
        
        
        
        
    }
    

    
    func yesTapped() {
        print("Accepted")
        
        // Close chat and go to another page with time and meet up location
        // If user opens app, it should go to a page with time and meet up location info
        // When the time for meet up, we ask the user if there have met up with this user
        
        chatAcceptPath.setValue("yes")
        
     
        
        
        
    }
    
    func noTapped() {
        print("Declined")
        
        chatAcceptPath.setValue("no")
        chatMsgPath.setValue(" ")
        self.updateTableView()
        
    }
    

    
    
    // Chat method
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        if textField == txtChat {
            
            if txtChat.text == "" {
                print("Cant accept empty input")
                warningLabel.text = "Cant accept empty input"
            } else {
                chatMessage = txtChat.text
                sendButton.alpha = 1.0
                messageCount = messageCount + 1
                warningLabel.text = ""
            }
           
        }
        
        return true
    }
    
    
    @IBAction func sendButton(sender: AnyObject) {
        
            print(chatDate)
            print(chatMessage)
        
            let toSendMessage = chatMessage + "\n" + chatDate
    
//            let messageDictionary: [String: String] = ["message": toSendMessage]
        
        if messageCount < 11 {
            

            print("message to send \(toSendMessage)")
            
            
            
            
            chatMsgPath.setValue("\(appDelegate.userIdentifier)_value_\(toSendMessage)")
            
            
        } else {
            print("Reached Chat Limit, Pls choose last sent location")
            
            warningLabel.text = "Reached Chat Limit, Pls choose last sent location"
            
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
//        cell.chatMessage.text = messagesArray[indexPath.row]["message"]
        cell.chatMessage.text = messagesArray[indexPath.row]
        
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
//        messagesArray = []
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "yesSegue") {
            
            let destVC = segue.destinationViewController as! MeetUpAndMapViewController
            
            let messageInfo = messagesArray[0]
            
            let messageInfoArray = messageInfo.componentsSeparatedByString("\n")
            
            destVC.time = messageInfoArray[1]
            destVC.destination = messageInfoArray[0]
            
            
        }
    }
    
    
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}

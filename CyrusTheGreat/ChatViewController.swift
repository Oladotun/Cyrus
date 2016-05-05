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


class ChatViewController: UIViewController, UITableViewDelegate, ChatViewDelegate, SearchTableDelegate {

    @IBOutlet weak var searchChat: UITextField!
    @IBOutlet weak var destinationLabel: UILabel!
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
    
    var searChatControll: SearchTableViewController!
    var handler:UInt!
    
//    var otherUserUID:String!
    
    var iamSender:Bool!
    var chatMsgPath: Firebase!
    var chatAcceptPath: Firebase!
    var userInvolved: Firebase!
    
    
    var selectedCoordinate:CLLocationCoordinate2D!
    var destinationLocation: CLLocation!
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iamSender = true
        
        print("initiator is \(initiator)")
        print("We are setting up to initiate")
        self.appDelegate.fireUID = "03d9149d-e014-4155-8b0a-0d1d8a74dfb4"
       chatMsgPath = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/chatMsg")
       chatAcceptPath = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/chatAccept")
        userInvolved = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/names")
        chatAcceptPath.setValue("no")
        appDelegate.userIdentifier = UIDevice.currentDevice().name
    
    
        
//        let initializeQuestion = appDelegate.meetUpFire.childByAppendingPath("questionController")
//        initializeQuestion.setValue("Not Set")
        
        let userName = [appDelegate.userIdentifier : appDelegate.userIdentifier]
        
        userInvolved.updateChildValues(userName)
        
        handler = userInvolved.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                
                if child.key != self.appDelegate.userIdentifier {
                    self.appDelegate.otherUserIdentifieir = child.key
                    
                }
                
            }
        })
        
        
        chatAcceptPath.observeEventType(.Value, withBlock: {
            snapshot in
            
            if(snapshot.value as! String == "yes") {
                
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                    print("called yes Segue")
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
                
                if (!val.isEmpty) {
                    let sendMsg = val.componentsSeparatedByString("_value_")
                    
                    if (sendMsg.count > 1) {
                        if(sendMsg[0] != self.appDelegate.userIdentifier ){
                            self.iamSender = false
                            
                            self.messagesArray = [String]()
                            if (sendMsg[1].contains("^_^")) {
                            
                            var itemAdd = sendMsg[1].componentsSeparatedByString("^_^")
                            print(itemAdd[1])
                                
                                if (itemAdd.count > 1) {
                                    
                                    if (itemAdd[1].contains("*_*")) {
                                        
                                        let coordinateString = itemAdd[1].componentsSeparatedByString("*_*")
                                        
                                        
                                        let latString = coordinateString[0]
                                        let longString = coordinateString[1]
                                        
                                        
                                        let lat = (latString as NSString).doubleValue
                                        let long = (longString as NSString).doubleValue
                                        
                                        let latDegrees: CLLocationDegrees = lat
                                        let longDegrees: CLLocationDegrees = long
                                        
                                        self.destinationLocation = CLLocation(latitude: latDegrees, longitude: longDegrees)
                                        
                                        //Update view after everything
                                        self.messagesArray.append(itemAdd[0])
                                        self.updateTableView()
                                        
                                    }

                                }
                            
                            
                            }
                            
                            
                        }
                        
                    }
                    
                } else {
                    print("Message path not set") 
                }
                    
                }
                
                
            
            
        })
        
        
        
        // Do any additional setup after loading the view.
        tblChat.delegate = self
        tblChat.dataSource = self
        searChatControll = SearchTableViewController()
        
        searChatControll.searchProtocol = self
        
        // Dynamic sizing of chat box
        tblChat.estimatedRowHeight = 60.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        txtChat.delegate = self
        searchChat.delegate = self
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
    
    // MARK: IBAction method implementation
    
    @IBAction func endChat(sender: AnyObject) {
       
        
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
    func cancel() {
        
        print ("cancelled was called from home")
                
    }
    
    
    
//    func selected(address:String) {
//        print("Passed address \(address)")
//        txtChat.text = address
//        
//    }
    func selected(address: String,completeAddress:String,coordinate:CLLocationCoordinate2D) {
        print ("table view selected")
        txtChat.text = address
        sendButton.alpha = 1.0
        chatMessage = address + "\n" + completeAddress
        selectedCoordinate = coordinate
        destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        updateChatDate()
        
    }
    
    @IBAction func sendButton(sender: AnyObject) {
    
        print(chatDate)
        print(chatMessage)
    
        let toSendMessage = chatMessage + "\n" + chatDate
        let sendCoordinateString = "\(selectedCoordinate.latitude)*_*\(selectedCoordinate.longitude)"
        if messageCount < 11 && !chatMessage.isEmpty {
            print("message to send \(toSendMessage)")
            chatMsgPath.setValue("\(appDelegate.userIdentifier)_value_\(toSendMessage)^_^\(sendCoordinateString)")
            self.iamSender = true
            updateChatDate()
            messagesArray = [String]()
            messagesArray.append(toSendMessage)
            updateTableView()
            txtChat.text = ""
            
            
        } else {
            if (chatMessage.isEmpty) {
                warningLabel.text = "Cannot Send Empty String"
            } else {
                print("Reached Chat Limit, Pls choose last sent location")
                warningLabel.text = "Reached Chat Limit, Pls choose last sent location"
            }
        }
    }
    
    
    func updateTableView() {
        
        self.tblChat.reloadData()
        if self.tblChat.contentSize.height > self.tblChat.frame.size.height {
            tblChat.scrollToRowAtIndexPath(NSIndexPath(forRow: messagesArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }
    
    @IBAction func unwindToChat(segue:UIStoryboardSegue) {
        print("unwinded")
        
    }
    
    
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "yesSegue") {
            
            let destVC = segue.destinationViewController as! MeetUpAndMapViewController
            
            let messageInfo = messagesArray.last!
            let messageInfoArray = messageInfo.componentsSeparatedByString("\n")
            destVC.time = messageInfoArray[2]
            destVC.placeAddress = messageInfoArray[1]
            destVC.destination = messageInfoArray[0]
            destVC.destinationLocation = destinationLocation
//            if (iamSender == true) {
//                chatMsgPath.setValue("")
//            }
            

        }
        
        if (segue.identifier == "searchTableId") {
            
            let nav = segue.destinationViewController as! UINavigationController
            
            let destVC = nav.topViewController as! SearchTableViewController
            destVC.searchProtocol = self
            
        }
        
        
    }

}

extension ChatViewController: UITextFieldDelegate {
    // Chat method
    func textFieldDidBeginEditing(textField: UITextField) {
        print("I began editing")
        if (textField == txtChat) {
            txtChat.text = ""
            txtChat.resignFirstResponder()
            performSegueWithIdentifier("searchTableId", sender: self)
//            searchChat.becomeFirstResponder()
            
        } else {
            
        }
        
    }

    
    
}

extension ChatViewController: UITableViewDataSource {
    
    // MARK: UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagesArray.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tblChat.dequeueReusableCellWithIdentifier("idCell")! as! ChatViewCell
        cell.chatMessage.text = messagesArray[indexPath.row]
        cell.chatMessage.alpha = 1.0
        cell.chatMessage.scrollEnabled = false
        
        print("Cell is being printed")
        print("count of message: \(messagesArray[indexPath.row])")
        if(indexPath.row == messagesArray.count - 1) {
            print("I am displaying")
            //            print(iamSender!)
            if (iamSender! == true) {
                cell.yesButton.alpha = 0.0
                cell.noButton.alpha = 0.0
            } else {
                cell.yesButton.alpha = 1.0
                cell.noButton.alpha = 1.0
            }
            
        }
        cell.chatViewProtocol = self
        //        messagesArray = []
        
        return cell
    }
    
    
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}


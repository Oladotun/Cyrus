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
import CoreLocation


class ChatViewController: UIViewController, UITableViewDelegate, ChatViewDelegate, SearchTableDelegate,FirebaseChatDelegate {

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
    
    var firebaseManager: FirebaseManager!
    var selectedCoordinate:CLLocationCoordinate2D!
    var destinationLocation: CLLocation!
    
    @IBOutlet weak var sendButton: UIButton!

    //Delegates
    func updateChat(chatMsg: String,location: CLLocation) {
        self.messagesArray = [String]()
        self.messagesArray.append(chatMsg)
        self.destinationLocation = location
        self.updateTableView()
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iamSender = false
        firebaseManager = appDelegate.userFirebaseManager
        firebaseManager.fireBaseChatDelegate = self
        
        self.appDelegate.otherUserIdentifieir = firebaseManager.connectedUserInfo.user.userId
        appDelegate.userIdentifier = firebaseManager.userId


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
            self.firebaseManager.updateChatAccept("\(self.firebaseManager.userObject.firstName)*_*_end_chat_")
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.alertEndChat.dismissViewControllerAnimated(true, completion: nil)

        }
        
        self.alertEndChat.addAction(acceptAction)
        self.alertEndChat.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(self.alertEndChat, animated: true, completion: nil)
        }
    }
    
    // Close chat and go to another page with time and meet up location
    // If user opens app, it should go to a page with time and meet up location info
    // When the time for meet up, we ask the user if there have met up with this user
    
    func yesTapped() {
        firebaseManager.updateChatAccept("Yes")
    }
    
    func noTapped() {
//        firebaseManager.updateChatMsgPath("No")
//        self.updateTableView()
        
    }
    func cancel() {
        
        print ("cancelled was called from home")
                
    }
    
    func segueToNextPage() {
        performSegueWithIdentifier("yesSegue", sender: self)
    }
    
    func meetUpCancelled(canceller: String) {
        firebaseManager.meetPathWay.removeValue()
        let alert = UIAlertController(title:"",message: "\(canceller) Ended the chat", preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(doneAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
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
            updateChatDate()
            
            self.updateChat(toSendMessage, location: destinationLocation)
            iamSender = true
            
//            let userMessageToSend = [String:String]()
//            userMessageToSend["message"] = ""
            firebaseManager.updateChatMsgPath("\(appDelegate.userIdentifier)_value_\(toSendMessage)^_^\(sendCoordinateString)")
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
        
        return cell
    }
    
    
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}


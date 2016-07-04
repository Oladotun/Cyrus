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
    @IBOutlet weak var txtChat: UITextField!
    @IBOutlet weak var meetTimePicker: UIDatePicker!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var buildName: UITextField!

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var alertEndChat:UIAlertController!
    var messagesArray: [String] = []
    
    @IBOutlet weak var warningLabel: UILabel!
    var chatMessage: String!
    var chatDate: String!
    var messageCount: Int!
    var initiator = false
    
    var searChatControll: SearchTableViewController!
    var myName:String!
    var iamSender:Bool!
    var firebaseChatManager: FirebaseChatManager!
    var address:String!
    var completeAddress:String!
    var buildNameTxt = ""

    
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
        restorationIdentifier = "ChatViewControllerId"
        restorationClass = ChatViewController.self
        
        if (iamSender == nil) {
             iamSender = false
        }
       
        if let userId = appDelegate.userIdentifier {
            firebaseChatManager.userId = userId
             firebaseChatManager.delegate = self
        }
        
       
        
        // Do any additional setup after loading the view.
        tblChat.delegate = self
        tblChat.dataSource = self
        searChatControll = SearchTableViewController()
        searChatControll.searchProtocol = self
        
        // Dynamic sizing of chat box
        tblChat.estimatedRowHeight = 60.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        tblChat.alwaysBounceHorizontal = false
        txtChat.delegate = self
        buildName.delegate = self
        searchChat.delegate = self
        updateChatDate()
        sendButton.alpha = 0.0
        messageCount = 0
        warningLabel.text = ""
        warningLabel.textColor = UIColor.redColor()

    }
  
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
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
        
    }
    
    // Restore Info
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        //1
        if let firebaseChat = firebaseChatManager {
            coder.encodeObject(firebaseChat, forKey: "firebaseChatManager")
        }
        if messagesArray.count > 0 {
            coder.encodeObject(messagesArray, forKey: "messagesArray")
            coder.encodeBool(iamSender, forKey: "sentLast")
        }
        
        
        //2
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        
        if let firebaseInfo = coder.decodeObjectForKey("firebaseChatManager") {
            firebaseChatManager = firebaseInfo as! FirebaseChatManager
            appDelegate.userIdentifier = firebaseChatManager.userId
        }
        
        if let shortAddress = coder.decodeObjectForKey("messagesArray") {
            messagesArray = shortAddress as! [String]
        }
        
        iamSender = coder.decodeBoolForKey("sentLast")
        
        
        super.decodeRestorableStateWithCoder(coder)
    }
    
    override func applicationFinishedRestoringState() {
        // Final configuration goes here.
        // Load images, reload data, e. t. c.
        
        guard let firebase = firebaseChatManager else {return}
        print("Decoded")
        firebase.delegate = self
        updateTableView()
        
    }
    
    static func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        let vc = ChatViewController()
        return vc
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func endChat(sender: AnyObject) {
        
        alertEndChat = UIAlertController(title: "", message: "Are you sure you want to end chat and meet up", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.firebaseChatManager.updateChatAccept("\(self.myName)*_*_end_chat_")
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
        firebaseChatManager.updateChatAccept("Yes")
    }
    
    func noTapped() {
//        firebaseManager.updateChatMsgPath("No")
//        self.updateTableView()
        
    }
    func cancel() {
        
    }
    
    func segueToNextPage() {
        
      performSegueWithIdentifier("yesSegue", sender: self)

        
    }
    
    func meetUpCancelled(canceller: String) {
        
        let alert = UIAlertController(title:"",message: "\(canceller) ended the chat", preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
    
            self.performSegueWithIdentifier("GoHomeSegue", sender: self)
        }
        
        alert.addAction(doneAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    func selected(address: String,completeAddress:String,coordinate:CLLocationCoordinate2D) {
        txtChat.text = address
        sendButton.alpha = 1.0
        self.address = address
        self.completeAddress = completeAddress
        selectedCoordinate = coordinate
        destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        updateChatDate()
        
    }
    
    @IBAction func sendButton(sender: AnyObject) {
        
        if let build = buildName.text {
            buildNameTxt = build
        }
        
        if (!buildNameTxt.isEmpty) {
            chatMessage = address + " (\(buildNameTxt))" + "\n" + completeAddress
        } else {
            chatMessage = address + "\n" + completeAddress
        }
        
       let toSendMessage = chatMessage + "\n" + chatDate
       let sendCoordinateString = "\(selectedCoordinate.latitude) \(selectedCoordinate.longitude)"
        
        if messageCount < 11 && !chatMessage.isEmpty {
            txtChat.resignFirstResponder()
            buildName.resignFirstResponder()
            buildName.text = ""
//            print("message to send \(toSendMessage)")
            updateChatDate()
            
            self.updateChat(toSendMessage, location: destinationLocation)
            iamSender = true
            
            var userMessageToSend = [String:String]()
            userMessageToSend["message"] = toSendMessage
            userMessageToSend["location"] = sendCoordinateString
            firebaseChatManager.updateChatMsgPath(appDelegate.userIdentifier,toSend: userMessageToSend)
            txtChat.text = ""
            
            
        } else {
            if (chatMessage.isEmpty) {
                warningLabel.text = "Cannot Send Empty String"
            } else {
//                print("Reached Chat Limit, Pls choose last sent location")
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
       
    
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "yesSegue" ) {
            
            let destVC = segue.destinationViewController as! MeetUpAndMapViewController
            print("the message is \(messagesArray)")
            let messageInfo = messagesArray.last!
            let messageInfoArray = messageInfo.componentsSeparatedByString("\n")
            destVC.time = messageInfoArray[2]
            destVC.placeAddress = messageInfoArray[1]
            destVC.destination = messageInfoArray[0]
            destVC.destinationLocation = destinationLocation
            destVC.firebaseMapManager = FirebaseMapManager(meetPath: firebaseChatManager.meetUpPathWay, myId: firebaseChatManager.userId, otherUserId: appDelegate.otherUserIdentifieir)
            destVC.firebaseMeetupInfoManager = FirebaseInfoMeetUpManager(meetPath: firebaseChatManager.meetUpPathWay,myId:firebaseChatManager.userId, otherUserId: appDelegate.otherUserIdentifieir)

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
        if (textField == txtChat) {
            txtChat.text = ""
            txtChat.resignFirstResponder()
            performSegueWithIdentifier("searchTableId", sender: self)

        }
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == buildName) {
            buildNameTxt = buildName.text!
//            print("Updated buildName info")
            buildName.resignFirstResponder()
           
        }
        
        return true
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
        if(indexPath.row == messagesArray.count - 1) {
            if (iamSender! == true) {
                cell.yesButton.alpha = 0.0
                cell.noButton.alpha = 0.0
            } else {
                cell.yesButton.alpha = 1.0
                cell.noButton.alpha = 0.0
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


//
//  QuestionsViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/31/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController,FirebaseQuestionDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let questionPrelude:[String] = ["tell us your favorite memories about","share a story on why you like" ,"tell us why you enjoy"]
    @IBOutlet weak var interestMatchLabel: UILabel!
    var countQuestions:Int = 0
    var endButtonPressed:Bool!
    @IBOutlet weak var questionButton: UIButton!
    var firebaseQuestionManager:FirebaseQuestionManager!
    var userToQuestions:[String:[String]]!
    var questionPerUser:Int!
    var allQuestionAsked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseQuestionManager.delegate = self
        userToQuestions = [String:[String]]()
        appDelegate.justMetUpWith = appDelegate.connectedProfile.user.userId
        
        if (appDelegate.iamInitiator == true) {
            questionButton.alpha = 1.0
            
        } else {
            questionButton.alpha = 0.0
            
        }
        
        
        if let interestCount = appDelegate.connectedProfile.userMatchedCount {
            questionPerUser = interestCount + 1 // we added 1 for the users field
            
        }
        
        interestMatchLabel.text = "Hi, Cyrus here. I am going to ask both of you about your interests to better assist with your convestations.\nClick the Next Question to start"
        interestMatchLabel.numberOfLines = 0
//        interestMatchLabel.preferredMaxLayoutWidth = 350
        
    }
    
    func updateQuestionLabel(question: String) {
        
        interestMatchLabel.text = question
        
    }
    
    func meetUpCancelled(canceller:String) {
        
        firebaseQuestionManager.meetUpPathWay.removeValue()
        let alert = UIAlertController(title:"",message: "\(canceller) ended meetings", preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            self.performSegueWithIdentifier("unWindHome", sender: self)
        }
        
        alert.addAction(doneAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    func chattingDone() {
        
        firebaseQuestionManager.meetUpPathWay.removeValue()
        let alert = UIAlertController(title:"",message: "Chat Done!\n Stay in touch with each others by sharing contact information such as Email, Linkedln, Facebook or Phone number.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            self.performSegueWithIdentifier("unWindHome", sender: self)
        }
        
        alert.addAction(doneAction)
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
  
    func questTime() {
        var userName = ""
        let myName = appDelegate.userObject.firstName
        let otherUserName = appDelegate.connectedProfile.user.firstName
        var question = ""
        var fieldInfo = ""
        var foundInterest = ""
        
        
        if (countQuestions % 2 == 0) {
            userName = myName.capitalizeFirst
            
        } else {
            userName = otherUserName.capitalizeFirst
        }
        if (userToQuestions[userName] == nil) {
            userToQuestions[userName] = [String]()
        }
        
        
        if (appDelegate.connectedProfile.userMatchedInterest.count > 5) {
            
            if (countQuestions == 2 || countQuestions == 5) {
                if (userName == myName.capitalizeFirst) {
                    fieldInfo = appDelegate.userObject.userField
                    
                } else {
                    fieldInfo = appDelegate.connectedProfile.user.userField
                    
                }
                
                question = "tell us how and why you decided to get into \(fieldInfo) ?"
                userToQuestions[userName]!.append(fieldInfo)
            } else {
                repeat {
                    foundInterest = appDelegate.connectedProfile.userMatchedInterest.randomItem()
                } while(userToQuestions[userName]!.contains(foundInterest))
                userToQuestions[userName]!.append(foundInterest)
                
                question = questionPrelude.randomItem() + " " + foundInterest + " ?"
                
            }
            
        } else {
            
            if (countQuestions == 1 || countQuestions == 2) {
                if (userName == myName.capitalizeFirst) {
                    fieldInfo = appDelegate.userObject.userField
                    
                } else {
                    fieldInfo = appDelegate.connectedProfile.user.userField
                    
                }
                
                question = "tell us how and why you decided to get into \(fieldInfo) ?"
                userToQuestions[userName]!.append(fieldInfo)
            } else {
                repeat {
                    foundInterest = appDelegate.connectedProfile.userMatchedInterest.randomItem()
                } while(userToQuestions[userName]!.contains(foundInterest))
                userToQuestions[userName]!.append(foundInterest)
                
                question = questionPrelude.randomItem() + " " + foundInterest + " ?"
                
            }
            
        }
    
        
        
        let completeQuestion = userName + ", " + question
        firebaseQuestionManager.questionPathFirebase.setValue(completeQuestion)
        
        if (appDelegate.iamInitiator == true) {
            updateQuestionLabel(completeQuestion)
            
        }
        allQuestionAsked = checkIfQuestionComplete()
//        print(userToQuestions)

        
    }
    
    func segueToMessages() {
        //
        self.performSegueWithIdentifier("MessagesSegue", sender: self)
    }
    
    func checkIfQuestionComplete() -> Bool {
        
        for key in userToQuestions.keys {
            if (userToQuestions[key]?.count < questionPerUser) {
                return false
            }
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextQuestion(sender: AnyObject) {
        
        if (allQuestionAsked == true) {
            chattingDone()
            self.firebaseQuestionManager.questionPathFirebase.setValue("_Done_")

        } else {
            questTime()
            countQuestions = countQuestions + 1
        }

        
    }
    
    @IBAction func exitButton(sender: AnyObject) {
        
        let alert = UIAlertController(title: "", message: "Are you sure you want to exit the chat?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            let userEnd = [self.appDelegate.userObject.firstName : "_end_chat_"]
            self.firebaseQuestionManager.questionPathFirebase.setValue(userEnd)
            
            
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    

    @IBAction func chatWithUser(sender: AnyObject) {
        firebaseQuestionManager.segueToMessages.setValue(appDelegate.userIdentifier)
        self.performSegueWithIdentifier("MessagesSegue", sender: self)
    }
    
    @IBAction func unwindQuestionController(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "MessagesSegue") {
            let navVC =  segue.destinationViewController as! UINavigationController
            let destinationVC = navVC.topViewController as! FindUserChatViewController
            destinationVC.messageRef = firebaseQuestionManager.meetUpPathWay.child("messages")
            destinationVC.senderId = appDelegate.userIdentifier
            destinationVC.senderDisplayName = appDelegate.userObject.firstName
            
        }
    }
    

}



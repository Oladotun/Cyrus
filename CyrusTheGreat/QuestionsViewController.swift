//
//  QuestionsViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/31/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase

class QuestionsViewController: UIViewController,FirebaseQuestionDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
   
    
    let questionPrelude:[String] = ["Tell us your favorite memories about","Share a story on why you like" ,"Tell us why you got into"]
    let fieldQuestion = "Tell us why you got into your field of study ?"
    
    @IBOutlet weak var interestMatchLabel: UILabel!
    
    var countQuestions:Int = 0

    var endButtonPressed:Bool!
    
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    var firebaseManager:FirebaseManager!
     var seenTopics = [String]()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseManager = appDelegate.userFirebaseManager
        firebaseManager.observeQuestionFirebase()
        firebaseManager.fireBaseQuestDelegate = self
        doneButton.alpha = 0.0
        if (firebaseManager.iamInitiator) {
            questionButton.alpha = 1.0
            
        } else {
            questionButton.alpha = 0.0
            
        }
        interestMatchLabel.text = "Press the next question button to start"
        interestMatchLabel.preferredMaxLayoutWidth = 350
        
        
        

    }
    
    func updateQuestionLabel(question: String) {
        interestMatchLabel.text = question
        
    }
    
    func meetUpCancelled(canceller:String) {
        
        firebaseManager.meetPathWay.removeValue()
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
        firebaseManager.meetPathWay.removeValue()
        let alert = UIAlertController(title:"",message: "Meet Up Chat Done", preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            self.performSegueWithIdentifier("unWindHome", sender: self)
        }
        
        alert.addAction(doneAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func doneButtonHit(sender: AnyObject) {
        
        
        let alert = UIAlertController(title: "", message: "Done Chatting ?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            self.firebaseManager.questionPathFirebase.setValue("_Done_")
            self.performSegueWithIdentifier("unWindHome", sender: self)
            
            
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func questTime() {
        var userName = ""
        var question = ""
        
        if (countQuestions % 2 == 0) {
            userName = firebaseManager.userObject.firstName
            
        } else {
            userName = firebaseManager.connectedUserInfo.user.firstName
        }
        
        question = questionPrelude.randomItem() + " " + firebaseManager.connectedUserInfo.userMatchedInterest.randomItem() + "?"
        
        if (countQuestions == 2 || countQuestions == 5) {
            question = fieldQuestion
            
            if (countQuestions == 5) {
                doneButton.alpha = 1.0
            }
        }
        
        let completeQuestion = userName + "," + question
        firebaseManager.questionPathFirebase.setValue(completeQuestion)
        
        if (firebaseManager.iamInitiator) {
            updateQuestionLabel(completeQuestion)
            
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextQuestion(sender: AnyObject) {

        questTime()
        countQuestions = countQuestions + 1
    }
    
    @IBAction func exitButton(sender: AnyObject) {
        
        let alert = UIAlertController(title: "", message: "Are you sure you want to exit the chat?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            self.firebaseManager.questionPathFirebase.setValue("\(self.firebaseManager.userObject.firstName)_end_chat_")
//            self.performSegueWithIdentifier("unwindExitQuestionHome", sender: self)
            
            
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
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

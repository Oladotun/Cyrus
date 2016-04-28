//
//  QuestionsViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/31/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase

class QuestionsViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var interestsCollected: String!
//    var interestDictionary = Dictionary<String, Int>()
    var interestSameArray: [String]!
    
    let questionPrelude:[String] = ["What are your favorite memories about ","Why do you like " ,"Why did you get into "]

    @IBOutlet weak var interestMatchLabel: UILabel!
    
    var timer = NSTimer() //make a timer variable, but do not do anything yet
    let timeInterval:NSTimeInterval = 1.0
    
    var numOfQuestions:Int = 1
    
    var endButtonPressed:Bool!
    var firstTopicFire:Firebase!
    var getMatchedTopicsFire:Firebase!
    var firstTopic:String!
    var questionController: Firebase!
    var nextQuestionFire:Firebase!
    var messageSetter:Bool!
    var nextQuestionSelected:Bool!
     var seenTopics = [String]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        endButtonPressed = false
//        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
//            
//            self.fireBaseBusiness()
//            
//        }
//       
//        interestMatchLabel.text = "What is your favorite thing about \(appDelegate.matchedTopic) ?"
//        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "questTime", userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view.
        
        messageSetter  = false
        nextQuestionSelected = false
        
        
        firstTopicFire = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/firstTopic")
        var questionAskedCount = 0
        
        
        firstTopicFire.observeEventType(.Value, withBlock: {
            snapshot in
            
            if (snapshot.value is NSNull) {
                print("we have a problem")
            } else {
                let receiveSentence = (snapshot.value as! String)
//                let prelude = self.questionPrelude.randomItem()
                
                let splitSent = receiveSentence.componentsSeparatedByString("_/|")
                print(splitSent)
                questionAskedCount = questionAskedCount + 1
                
                if (splitSent.count > 1) {
                    self.interestMatchLabel.text = "\(splitSent[0]) \(splitSent[1]) ?"
                    
                } else {
                    self.interestMatchLabel.text = "Why do you like \(receiveSentence) ?"
                    self.firstTopic = receiveSentence
                    
                }
//                let preludePresent = self.firstTopic
                
                
//                self.timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "questTime", userInfo: nil, repeats: true)
                
            }
            
        })
        
        
        getMatchedTopicsFire = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/matchedTopics")
        
        getMatchedTopicsFire.observeEventType(.Value, withBlock: {
            snapshot in
            
            if(snapshot.value is NSNull) {
                print("Problem getting matched topics from question page")
            } else {
                self.interestSameArray = (snapshot.value as! [String])
                
            }
        })
        
        questionController = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/questionController")
        
        questionController.observeEventType(.Value, withBlock: {
            snapshot in
            
            if(snapshot.value is NSNull) {
                print("Problem present in extracting question")
            } else {
                
                let questionAsker = (snapshot.value as! String)
                
                if (questionAsker == "Not Set"){
                    self.questionController.setValue(self.appDelegate.userIdentifier)
                    
                } else {
                    
                    if (questionAsker == self.appDelegate.userIdentifier) {
                        self.messageSetter = true
                    }
                    
                    
                }
            }
        })
        
        nextQuestionFire = appDelegate.meetUpFire.childByAppendingPath("nextQuestion")
        let nextQuestion = [appDelegate.userIdentifier: "no"]
        
        nextQuestionFire.updateChildValues(nextQuestion)
        
        
        nextQuestionFire.observeEventType(.Value, withBlock: {
            snapshot in
            if (snapshot.childrenCount > 0) {
                
                for child in snapshot.children {
                    
                    if child.key != self.appDelegate.userIdentifier {
                        
                        let childSnapshot = snapshot.childSnapshotForPath(child.key)
                        
                         if let nextQuestionSelectedValue = childSnapshot.value as? String {
                            
                            if (nextQuestionSelectedValue == "yes" && self.nextQuestionSelected == true) {
                             
                                self.seenTopics.append(self.firstTopic)
                                if (self.messageSetter == true) {
                                
                                    if (self.interestSameArray.count < 5 && (self.seenTopics.count == self.interestSameArray.count) ) {
                                        
                                        self.firstTopicFire.setValue("Share the Story of why you_/|decided to go into your field of study")
                                        
                                    } else {
                                        
                                        if (self.seenTopics.count == 5) {
                                           self.firstTopicFire.setValue("Share the Story of why you_/|decided to go into your field of study")
                                        } else {
                                            
                                            var interest: String!
                                            var topicFound = false
                                            
                                            repeat {
                                                interest = self.interestSameArray.randomItem()
                                                for seenTopic in self.seenTopics {
                                                    if (interest == seenTopic) {
                                                        topicFound = true
                                                    }
                                                }
                                                
                                            } while(topicFound == true)
                                            self.seenTopics.append(interest)
                                            
                                            let prelude = self.questionPrelude.randomItem()
                                            let topicToSend = "\(prelude)_/|\(interest)"
                                            
                                            
                                            self.firstTopicFire.setValue(topicToSend)
                                            
                                        }
                                        
                                        
                                        
                                    }
                                
                                }
                                

                                self.nextQuestionSelected = false
                                self.nextQuestionFire.updateChildValues(nextQuestion)
                                
                            }

                        }
                    }
                }
            }
        })
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextQuestion(sender: AnyObject) {
        self.nextQuestionSelected = true
        
        let nextQuestion = [appDelegate.userIdentifier: "yes"]
        
        nextQuestionFire.updateChildValues(nextQuestion)
        
        
    }
    
    @IBAction func exitButton(sender: AnyObject) {
        
        let alert = UIAlertController(title: "", message: "Are you sure you want to exit the chat?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            self.appDelegate.fireConnect.setValue("_end_chat_")
            self.endButtonPressed = true
            
            
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func lastQuestion(sender: AnyObject) {
    }
    
    func questTime() {
        if (numOfQuestions >= 4) {
            timer.invalidate()
        } else {
            if (numOfQuestions < 3) {
                
                let prelude = questionPrelude.randomItem()
                var interest = interestSameArray.randomItem()
                
                while (interest == firstTopic) {
                    interest = interestSameArray.randomItem()
                }
                
                interestMatchLabel.text = "\(prelude) \(interest) ?"
                
            } else {
                interestMatchLabel.text = "\(questionPrelude[2]) Engineering ?"
            }
            

        }
        
         numOfQuestions = numOfQuestions + 1
        
        
        
        
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

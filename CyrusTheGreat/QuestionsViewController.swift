//
//  QuestionsViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/31/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var interestsCollected: String!
    var interestDictionary = Dictionary<String, Int>()
    var interestSameArray: [String]!
    
    let questionPrelude:[String] = ["What is your favorite thing about ","Why do you like " ,"Why did you get into "]

    @IBOutlet weak var interestMatchLabel: UILabel!
    
    var timer = NSTimer() //make a timer variable, but do not do anything yet
    let timeInterval:NSTimeInterval = 1.0
    
    var numOfQuestions:Int = 1
    
    var endButtonPressed:Bool!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        endButtonPressed = false
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            self.fireBaseBusiness()
            
        }
       
        interestMatchLabel.text = "What is your favorite thing about \(appDelegate.matchedTopic) ?"
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "questTime", userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    func fireBaseBusiness() {
        appDelegate.myFire.observeEventType(.Value, withBlock: {
            //            snapshot.childrenCount()
            snapshot in
            print("\(snapshot.key) -> \(snapshot.value)")
            
            let eachPerson = snapshot.value as! NSDictionary
            
           let allValues = eachPerson.allValues as! [String]
            
            print("all values \(allValues)")
            
            for value in allValues {
                
//                let allInterests = snapshot.value as! String
                // Working on user topics and Matching topics
                if value.contains(":") {
                    
                    let twitInterest = value.componentsSeparatedByString(":")
                    
                    self.interestsCollected = twitInterest[1].stringByReplacingOccurrencesOfString("[", withString: "")
                    self.interestsCollected = self.interestsCollected.stringByReplacingOccurrencesOfString("]", withString: "")
                    print("twitter interests \(self.interestsCollected)")
                    
                    let twitInterestArray =  self.interestsCollected.componentsSeparatedByString(",")
                    
                    
                    print("twitter interest array \(twitInterestArray)")
                    
                    for interest in twitInterestArray {
                        
                        if let count = self.interestDictionary[interest] {
                            self.interestDictionary[interest] = count + 1
                        } else {
                            self.interestDictionary[interest] = 1
                        }
                        
                    }
                   
                } else {
                    
                    if value.contains("_end_chat_") {
                        
                        if(!self.endButtonPressed) {
                            
                            // In this case an "_end_chat_" message was received.
                            // Show an alert view to the user.
                            
                            let alert = UIAlertController(title:"",message: "Other User ended this chat", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    
//                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                            
                            alert.addAction(doneAction)
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                            
                        }
                        
                    }
                    
                    
                    
                }
                
                
                    
            }
            
             self.interestSameArray = Array(self.interestDictionary.keys)
                
//            self.interestMatchLabel.text = "\(self.interestDictionary)"
//            print("current dictionary: \(self.interestDictionary)")
            
            
            //            snapshot
        })
        
        
        
//        interestMatchLabel.text = "\(interestDictionary)"
    }
    
    
    func questTime() {
        if (numOfQuestions >= 4) {
            timer.invalidate()
        } else {
            if (numOfQuestions < 3) {
                
                interestMatchLabel.text = "What is your favorite thing about \(interestSameArray[numOfQuestions]) ?"
                
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

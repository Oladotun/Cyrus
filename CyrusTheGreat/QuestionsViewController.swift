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
    
    let questionPrelude:[String] = ["What is your favorite thing about ","Why do you like " ,"Why did you get into "]

    @IBOutlet weak var interestMatchLabel: UILabel!
    
    var timer = NSTimer() //make a timer variable, but do not do anything yet
    let timeInterval:NSTimeInterval = 1.0
    
    var numOfQuestions:Int = 1
    
    var endButtonPressed:Bool!
    var firstTopicFire:Firebase!
    var getMatchedTopicsFire:Firebase!
    var firstTopic:String!
   
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
        
        
        
        firstTopicFire = Firebase(url: "https://cyrusthegreat.firebaseio.com/\(self.appDelegate.fireUID)/firstTopic")
        
        
        firstTopicFire.observeEventType(.Value, withBlock: {
            snapshot in
            
            if (snapshot.value is NSNull) {
                print("we have a problem")
            } else {
                self.firstTopic = (snapshot.value as! String)
                self.interestMatchLabel.text = "What are your favorite memories about \(self.firstTopic) ?"
                
                self.timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "questTime", userInfo: nil, repeats: true)
                
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

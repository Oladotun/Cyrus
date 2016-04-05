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

    @IBOutlet weak var interestMatchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            self.interestMatch()
            
        }
        interestMatchLabel.text = "What is your favorite thing about \(appDelegate.matchedTopic) ?"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func interestMatch() {
        appDelegate.myFire.observeEventType(.Value, withBlock: {
            //            snapshot.childrenCount()
            snapshot in
            print("\(snapshot.key) -> \(snapshot.value)")
            
            let eachPerson = snapshot.value as! NSDictionary
            
           let allValues = eachPerson.allValues as! [String]
            
            print("all values \(allValues)")
            
            for value in allValues {
                
//                let allInterests = snapshot.value as! String
                
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
                
            }
//            self.interestMatchLabel.text = "\(self.interestDictionary)"
//            print("current dictionary: \(self.interestDictionary)")
            
            
            //            snapshot
        })
        
        
        
//        interestMatchLabel.text = "\(interestDictionary)"
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

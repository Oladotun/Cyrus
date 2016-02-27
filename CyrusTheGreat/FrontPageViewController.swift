//
//  FrontPageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 2/16/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit

class FrontPageViewController: UIViewController {

    @IBOutlet weak var logoCyrus: UIImageView!
    
    var cyrusText = "Hi there,my name is Cyrus The Great.\n I founded the Achaemedid empire that comprised of many nations.\n\nDuring my time(between 559-530 B.C), I was passionate about human rights,politics and influencing civilizations.\nI brought peace to nations I conquered by respecting their existing customs and views.\n\nToday,my goal is to connect you with people who share similar interest with you so you can learn and discuss about those views.\n\nKindly Sign Up or Login to start connecting.\n\n"
    var cyrusIntroWords: [Character]!
    var myCounter = 0
    var timer:NSTimer?

    @IBOutlet weak var cyrusIntro: UILabel!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var login: UIButton!
    var wordTimeInterval = 0.09
    
    func fireTimer(startTime:Float){
        var timeSchedule = NSTimeInterval(0.5 + startTime)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(timeSchedule, target: self, selector: "typeLetter", userInfo: nil, repeats: true)
        
        cyrusIntroWords = Array(self.cyrusText)
        
        
        var endDouble = timeSchedule + (Double(cyrusIntroWords.count) * wordTimeInterval) + 0.3
        var endTime = NSTimeInterval(endDouble)
       
        UIView.animateWithDuration(1.5, delay: endTime, options: .CurveEaseInOut, animations: {
            self.login.alpha = 1.0
            self.signUp.alpha = 1.0
        }, completion: nil)
    }
    
    
    func typeLetter(){
        
        // whent the TimeInterval is 0.0 implies we need to escape the word
        if wordTimeInterval == 0.0 {
            cyrusIntro.text = cyrusText
            timer?.invalidate()
            self.signUp.layer.removeAllAnimations()
            self.login.layer.removeAllAnimations()
            self.login.alpha = 1.0
            self.signUp.alpha = 1.0
            
        } else if myCounter < cyrusIntroWords.count {
            cyrusIntro.text = cyrusIntro.text! + String(cyrusIntroWords[myCounter])
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(wordTimeInterval), target: self, selector: "typeLetter", userInfo: nil, repeats: false)
        } else {
            timer?.invalidate()
        }
        myCounter++
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        logoCyrus.image = UIImage(named:"cyrus")
        logoCyrus.alpha = 0.0
        

        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.logoCyrus.alpha = 1.0
        }, completion: nil)
        fireTimer(0.5)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUp.layer.cornerRadius = 5
        signUp.layer.borderWidth = 1
        signUp.layer.borderColor = UIColor.blackColor().CGColor
        signUp.alpha = 0.0
        login.layer.cornerRadius = 5
        login.layer.borderWidth = 1
        login.layer.borderColor = signUp.layer.borderColor
        login.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("tapFunction:"))
        cyrusIntro.addGestureRecognizer(tap)
        cyrusIntro.userInteractionEnabled = true
        

        // Do any additional setup after loading the view.
    }
    
    func tapFunction(sender:UITapGestureRecognizer) {
        print("Tap Selected\n")
        self.wordTimeInterval = 0.0
    
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

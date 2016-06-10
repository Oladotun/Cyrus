//
//  FrontPageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 2/16/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase

class FrontPageViewController: UIViewController {

    @IBOutlet weak var logoCyrus: UIImageView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var cyrusText = "Hi there,my name is Cyrus.\n\nToday, my goal is to connect you with people who you share similar interest with, so you can learn from their views.\n\nKindly Sign Up or Login to start connecting.\n"
    let paragraphStyle = NSMutableParagraphStyle()

    var cyrusIntroWords: [Character]!
    var myCounter = 0
    var timer:NSTimer?
    var returnBack = false

    
    @IBOutlet weak var cyrusIntro: UILabel!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var login: UIButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get user logged in
        var autData:AnyObject?
        if (returnBack) {
             autData = nil
        } else {
          autData = NSUserDefaults.standardUserDefaults().valueForKey("uid")
        }

        if let autData = autData {
            appDelegate.userIdentifier = autData as! String
            
            let userInterests = appDelegate.userFire.child("users").child("\(autData)/interests")
            
            //Firebase(url:  "https://cyrusthegreat.firebaseio.com/users/\(autData)/interests")

            userInterests.observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                if (snapshot.value != nil) {
                    
                    if (snapshot.value is NSNull) {
                        
                        self.performSegueWithIdentifier("CotinueSignUp", sender: self)
                        
                    } else {
                        
                        //                    interests = (snapshot.value as? [String])!
                        self.performSegueWithIdentifier("AlreadyLoggedIn", sender: self)
                    }
                    
                }
                
            })
            
        } else {
            logoCyrus.image = UIImage(named:"cyrus")
            logoCyrus.alpha = 0.0
            
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.logoCyrus.alpha = 1.0
                }, completion: nil)
            
            UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseInOut, animations: {
                self.cyrusIntro.alpha = 1
                }, completion: nil)
            
            UIView.animateWithDuration(1.0, delay: 2.0, options: .CurveEaseInOut, animations: {
                self.login.alpha = 1.0
                self.signUp.alpha = 1.0
                }, completion: nil)
            
        }
        
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
        
        // Used in aligning text messages
        paragraphStyle.alignment = NSTextAlignment.Justified
        
        let attributedString = NSAttributedString(string: cyrusText,
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSBaselineOffsetAttributeName: NSNumber(float: 0)
            ])
        
        cyrusIntro.attributedText = attributedString
        cyrusIntro.font = UIFont(name: "Helvetica-Light", size: 15.0)
        cyrusIntro.alpha = 0.0
        
        
        
        

        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loggedOutPageController(segue:UIStoryboardSegue) {
        print("logged out succesfully")
 
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        returnBack = true
    }
    

}

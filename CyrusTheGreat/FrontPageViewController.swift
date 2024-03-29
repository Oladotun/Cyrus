//
//  FrontPageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 2/16/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//
// just to be let out

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
    var verified = false
    var pageValue = 0
    var segued = false

    
    @IBOutlet weak var cyrusIntro: UILabel!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var login: UIButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get user logged in
        var autData:AnyObject? = nil
        if (returnBack) {
             autData = nil
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
            
        
        } else {
            
            if let user = FIRAuth.auth()?.currentUser {
                appDelegate.firebaseUser = user
                
                autData = user.uid
                verified = user.emailVerified
                
                if (!verified) {
                    // segue to user page
                    appDelegate.userIdentifier = user.uid
                    self.performSegueWithIdentifier("VerifyEmailSegue", sender: self)
                    
                } else {
                
                    if let autData = autData {
                        appDelegate.userIdentifier = autData as! String
                        
                        let userProfileImage = appDelegate.userFire.child("users").child("\(autData)/image")
                        userProfileImage.observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            if ((snapshot.value is NSNull) || snapshot.value == nil) {
                                if(!self.segued) {
                                    self.segued = true
                                    self.performSegueWithIdentifier("CotinueSignUp", sender: self)
 
                                }

                            } else {
                                self.pageValue = self.pageValue + 1
                                if (self.pageValue > 1) {
                                    self.performSegueWithIdentifier("AlreadyLoggedIn", sender: self)
                                }

                            }
                        })
                        
                        let userInterests = self.appDelegate.userFire.child("users").child("\(autData)/interests")
                        userInterests.observeSingleEventOfType(.Value, withBlock: { snapshot in
                            if ((snapshot.value is NSNull)||snapshot.value == nil) {
                               
                                if (!self.segued) {
                                    self.segued = true
                                    self.performSegueWithIdentifier("CotinueSignUp", sender: self)
                                    
                                }
 
                            } else {
                                self.pageValue = self.pageValue + 1
                                if (self.pageValue > 1) {
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
//        print("logged out succesfully")
 
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        returnBack = true
    }
    

}

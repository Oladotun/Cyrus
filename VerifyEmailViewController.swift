//
//  VerifyEmailViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 6/10/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase

class VerifyEmailViewController: UIViewController {
  
    var timer:NSTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("checkEmailVerified"), userInfo: nil, repeats: true)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkEmailVerified() {
        
        FIRAuth.auth()?.currentUser?.reloadWithCompletion(nil)
       
        if let verifyStatus = FIRAuth.auth()?.currentUser?.emailVerified {
            if (verifyStatus) {
                timer.invalidate()
                self.performSegueWithIdentifier("ProfilePictureSegue", sender: self)
                
            }
            
        }

        
    }
    
    
    @IBAction func openMail(sender: AnyObject) {
        
        
        let mailURL = NSURL(string: "message://")!
        if UIApplication.sharedApplication().canOpenURL(mailURL) {
            UIApplication.sharedApplication().openURL(mailURL)
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

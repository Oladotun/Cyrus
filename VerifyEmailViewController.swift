//
//  VerifyEmailViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 6/10/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit

class VerifyEmailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

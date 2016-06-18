//
//  LoginPageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 4/26/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class LoginPageViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passField: UITextField!
    var interests = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passField.delegate = self
        passField.secureTextEntry = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    @IBAction func loginButton(sender: AnyObject) {
        
        if (emailTextField.text!.isEmpty || passField.text!.isEmpty ) {
            emailTextField.checkEmptyField()
            passField.checkEmptyField()
        } else {
            
            if (checkEmailDomain(getDomainFromEmail(emailTextField.text!.trim()))) {
                FIRAuth.auth()?.signInWithEmail(self.emailTextField.text!.trim(), password: self.passField.text!, completion:{ user, error in
                    if error != nil {
                        // Something went wrong. :(
                       self.alertView("Invalid Email or Password")
                    } else {
                        // Authentication just completed successfully :)
                        // The logged in user's unique identifier
                        
                        self.appDelegate.userIdentifier = user?.uid
                        // Get the user interests from firebase
                        let userInterests = self.appDelegate.userFire.child("users/\( self.appDelegate.userIdentifier)/interests")
                        
                        //Used to keep user logged in
                        NSUserDefaults.standardUserDefaults().setValue( self.appDelegate.userIdentifier, forKey: "uid")
                    
                        userInterests.observeEventType(.Value, withBlock: {
                            snapshot in
                            if (snapshot.value == nil) {
                                
                                self.performSegueWithIdentifier("NoInterestSegue", sender: self)
                                
                            } else {
        
                                self.interests = (snapshot.value as? [String])!
                                self.performSegueWithIdentifier("LoginHomeSegue", sender: self)
                                }
                                
                            
                            
                        })

                    }

                })
                
            } else {
//                print ("wrong email domain entered")
                emailTextField.errorHighlightTextField("School email required")
            }
            
        }
    }
    
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == emailTextField) {
            let enteredWord = emailTextField.text!
            if (!enteredWord.isEmail || enteredWord.isEmpty) {
                textField.errorHighlightTextField("School Email required")
            } else {
                textField.removeErrorHighlightTextField()
                passField.becomeFirstResponder()
            }
        }
        
        if (textField == passField) {
            let enteredWord = passField.text!
            
            if (enteredWord.isEmpty) {
                textField.errorHighlightTextField("Password required")
                textField.resignFirstResponder()
            } else {
                textField.removeErrorHighlightTextField()
                passField.resignFirstResponder()
            }
        }
        return true
        
    }
    
    
    
    func getDomainFromEmail(email:String) -> String {
        
        if (email.contains("@")) {
            let indexOfDomain = email.characters.indexOf("@")
            let indexDomain = email.characters.startIndex.distanceTo(indexOfDomain!) + 1
            let emailString = (email as NSString).substringFromIndex(indexDomain)
            return emailString
            
        } else {
            emailTextField.errorHighlightTextField("School Email required")
            return ""
        }
 
    }
    
    
    func checkEmailDomain(domainCheck:String) -> Bool {
        
        if domainCheck.isEmpty {
            return false
        }
        let path = NSBundle.mainBundle().pathForResource("usa_uni", ofType: "json")
        let jsonData = NSData(contentsOfFile:path!)
        let json = JSON(data:jsonData!)
        
        if let jsonArray = json.array {
            for item in jsonArray {
                if let jsonDict = item.dictionary { //  jsonDict : [String: JSon]
                    let domain = jsonDict["domain"]!.stringValue
                    if (domainCheck == domain) {
                        
                        return true
                    }
                    
                }
            }
        }
        
        return false
        
    }
    
    func alertView(message:String) {
        
        let alert = UIAlertController(title:"",message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(doneAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//        
//    }


}

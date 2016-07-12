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
    var pageValue = 0
    var segued = false

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
            
            FIRAuth.auth()?.signInWithEmail(self.emailTextField.text!.trim(), password: self.passField.text!, completion:{ user, error in
                if error != nil {
                    // Something went wrong. :(
                   self.alertView("Invalid Email or Password")
                } else {
                    // Authentication just completed successfully :)
                    // The logged in user's unique identifier
                    if let currUser = user {
                        
                        self.appDelegate.firebaseUser = currUser
                        
                        self.appDelegate.userIdentifier = currUser.uid
                        // Get the user interests from firebase
                        let userProfileImage = self.appDelegate.userFire.child("users").child("\(currUser.uid)/image")
                        userProfileImage.observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            if ((snapshot.value is NSNull) || snapshot.value == nil) {
                                if(!self.segued) {
                                    self.pageValue = -1
                                    self.segued = true
                                    self.performSegueWithIdentifier("NoInterestSegue", sender: self)
                                }
                                
                            } else {
                                self.pageValue = self.pageValue + 1
                                if (self.pageValue > 1) {
                                    self.performSegueWithIdentifier("LoginHomeSegue", sender: self)
                                }
                                
                            }
                        })
                        
                        let userInterests = self.appDelegate.userFire.child("users").child("\(currUser.uid)/interests")
                        userInterests.observeSingleEventOfType(.Value, withBlock: { snapshot in
                            if ((snapshot.value is NSNull)||snapshot.value == nil) {
                                if (!self.segued) {
                                    self.pageValue = -2
                                     self.segued = true
                                    self.performSegueWithIdentifier("NoInterestSegue", sender: self)
                                }
                                
                            } else {
                                self.pageValue = self.pageValue + 1
                                if (self.pageValue > 1) {
                                    self.performSegueWithIdentifier("LoginHomeSegue", sender: self)
                                }

                            }

                        })
                        
                    }

                }

            })
                
            
            
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
    
    
    @IBAction func sendPasswordReset(sender: AnyObject) {

        if (emailTextField.text!.isEmpty  ) {
            emailTextField.checkEmptyField()
            
        } else {
            FIRAuth.auth()?.sendPasswordResetWithEmail(emailTextField.text!, completion: nil)
            alertView("Password Reset sent to your email \(emailTextField.text!)")
  
        }
    }
    

//    
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

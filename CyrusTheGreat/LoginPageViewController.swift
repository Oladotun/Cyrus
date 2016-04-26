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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButton(sender: AnyObject) {
        
        if (emailTextField.text!.isEmpty || passField.text!.isEmpty ) { // || passwordField.text!.isEmpty || firstNameField.text!.isEmpty || lastNameField.text!.isEmpty
            
            print ("Please fill the empty field above")
            
        } else {
            
            if (checkEmailDomain(getDomainFromEmail(emailTextField.text!))) {
                
                self.appDelegate.userFire.authUser(self.emailTextField.text!, password: self.passField.text!, withCompletionBlock: { error, authData in
                    if error != nil {
                        // Something went wrong. :(
                    } else {
                        // Authentication just completed successfully :)
                        // The logged in user's unique identifier
                        print(authData.uid)
                        
                        // Set uid for local identifier
                        
                        self.appDelegate.userIdentifier = authData.uid
                       
                        // Initialize mpc manager with user identifier
                        self.appDelegate.mpcManager = MPCManager()
                        
                        // Get the user interests from firebase
                        let userInterests = Firebase(url:  "https://cyrusthegreat.firebaseio.com/users/\(authData.uid)/interests")
                        
                        userInterests.observeEventType(.Value, withBlock: {
                            snapshot in
                            if (snapshot.value != nil) {
                                
                                if (snapshot.value is NSNull) {
                                    
                                    print("We have a problem of no interest")
                                    self.performSegueWithIdentifier("NoInterestSegue", sender: self)
                                    
                                } else {
                                    print(snapshot.value)
                                    self.interests = (snapshot.value as? [String])!
                                    
                                     self.performSegueWithIdentifier("LoginHomeSegue", sender: self)
                                    }
                                
                            }
                            
                        })
                        
                        
                       
                        
                    }
                    
                    
                })
                
            } else {
                print ("wrong email domain entered")
            }
            
        }
    }
    
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
       
        
        if (textField == emailTextField) {
            
            let enteredWord = emailTextField.text!
            
            if (!enteredWord.isEmail || enteredWord.isEmpty) {
                print("wrong input")
            } else {
                passField.becomeFirstResponder()
            }
        }
        
        if (textField == passField) {
            let enteredWord = passField.text!
            
            if (enteredWord.isEmpty) {
                print ("wrong input")
            } else {
                passField.resignFirstResponder()
            }
        }
        
        
        return true
        
    }
    
    
    
    func getDomainFromEmail(email:String) -> String {
        
        let indexOfDomain = email.characters.indexOf("@")
        let indexDomain = email.characters.startIndex.distanceTo(indexOfDomain!) + 1
        let emailString = (email as NSString).substringFromIndex(indexDomain)
        
        return emailString
        
    }
    
    
    func checkEmailDomain(domainCheck:String) -> Bool {
        let path = NSBundle.mainBundle().pathForResource("usa_uni", ofType: "json")
        let jsonData = NSData(contentsOfFile:path!)
        let json = JSON(data:jsonData!)
        
        if let jsonArray = json.array {
            for item in jsonArray {
                if let jsonDict = item.dictionary { //  jsonDict : [String: JSon]
                    let domain = jsonDict["domain"]!.stringValue
                    if (domainCheck == domain) {
                        print("found array")
//                        print("our school name \(schoolName)")
                        
                        return true
                    }
                    
                }
            }
        }
        
        return false
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "LoginHomeSegue") {
            let destinationVC = segue.destinationViewController as! HomePageViewController
            
            destinationVC.interests = self.interests
            
        }
        
//        if (segue.identifier == "NoInterestSegue") {
//            
//            let destinationVC = segue.destinationViewController as! ApiConnectorViewController
//            
//        }
    }


}

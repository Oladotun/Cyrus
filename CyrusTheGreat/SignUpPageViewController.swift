//
//  SignUpPageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 2/18/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import SwiftyJSON

class SignUpPageViewController: UIViewController,UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var userLogo: UIImageView!    
    @IBOutlet weak var cyrusTalkLabel: UILabel!
    
    
    @IBOutlet weak var schoolEmailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var schoolName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLogo.image = UIImage(named:"cyrus")
        
        cyrusTalkLabel.text = "Hi,Cyrus here,I would like to know more about you."
        cyrusTalkLabel.textAlignment = NSTextAlignment.Left
        
        schoolEmailField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        passwordField.delegate = self
        
     

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButton(sender: AnyObject) {
        
        if (schoolEmailField.text!.isEmpty || passwordField.text!.isEmpty || firstNameField.text!.isEmpty || lastNameField.text!.isEmpty ) { // || passwordField.text!.isEmpty || firstNameField.text!.isEmpty || lastNameField.text!.isEmpty
            
            print ("Please fill the empty field above")
            
        } else {
            
            print(schoolEmailField.text!)
            if (checkEmailDomain(getDomainFromEmail(schoolEmailField.text!))) {
                appDelegate.userFire.createUser(schoolEmailField.text!, password: passwordField.text!,
                    withValueCompletionBlock: { error, result in
                        if error != nil {
                            // There was an error creating the account
                            print(error)
                        } else {
                            let uid = result["uid"] as? String
                            print("Successfully created user account with uid: \(uid)")
                            print(uid)
                            // Database might not be needed
                            
//                            let managedContext = self.appDelegate.managedObjectContext
//                            
//                            //2
//                            let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext:managedContext)
//                            
//                            let newUser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
//                            
//                            newUser.setValue(uid!, forKey: "f_id")
//                            newUser.setValue(self.schoolEmailField.text!, forKey: "email")
//                            newUser.setValue(self.firstNameField.text!, forKey: "first_name")
//                            newUser.setValue(self.lastNameField.text!, forKey: "last_name")
                            
                            
                            
                            
                            
                            self.appDelegate.userFire.authUser(self.schoolEmailField.text!, password: self.passwordField.text!, withCompletionBlock: { error, authData in
                                if error != nil {
                                    // Something went wrong. :(
                                } else {
                                    // Authentication just completed successfully :)
                                    // The logged in user's unique identifier
                                    print(authData.uid)
                                    
                                    // Set uid for local identifier
                                    
                                    self.appDelegate.userIdentifier = authData.uid
                                    // Create a new user dictionary accessing the user's info
                                    // provided by the authData parameter
                                    let newUser = [
                                        "first_name": self.firstNameField.text!,
                                        "last_name": self.lastNameField.text!,
                                        "school_name": self.schoolName
                                    ]
                                    // Create a child path with a key set to the uid underneath the "users" node
                                    // This creates a URL path like the following:
                                    //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                                    self.appDelegate.userFire.childByAppendingPath("users")
                                        .childByAppendingPath(authData.uid).setValue(newUser)
                                    
                                    // Initialize mpc manager with user identifier
//                                    self.appDelegate.mpcManager = MPCManager()
                                    self.performSegueWithIdentifier("connectTwitter", sender: self)

                                }

                                
                                
                                
                            })
                            
                            
//                            self.performSegueWithIdentifier("connectTwitter", sender: self)
                            
                            
//                            do {
//                                try managedContext.save()
//                                
//                                self.performSegueWithIdentifier("connectTwitter", sender: self)
//                                print("user info was saved")
//                            } catch let error as NSError {
//                                print("Could not save \(error), \(error.userInfo)")
//                            }
                            
                            
                        }
                })
                
            } else {
                
                print ("wrong usa student domain")
                
            }

            
        }
        
    
        
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
                        schoolName = jsonDict["name"]!.stringValue
                        print("found array")
                        print("our school name \(schoolName)")
                        
                        return true
                    }
 
                }
            }
        }
        
        return false
        
    }
    
    
    
    // MARK: - TextField Delegate 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == schoolEmailField) {
            
            let enteredWord = schoolEmailField.text!
            
            if (!enteredWord.isEmail || enteredWord.isEmpty) {
                
                print("Invalid Input")
                
            } else {
                firstNameField.becomeFirstResponder()
                
            }
//            schoolEmailField.resignFirstResponder()
            
        }
//        
        if (textField == firstNameField) {
            
            let firstName = firstNameField.text!
            
            if (firstName.isEmpty) {
                print("Enter input")
            } else {
                lastNameField.becomeFirstResponder()
            }
        }
        
        if (textField == lastNameField) {
            let lastName = lastNameField.text!
            
            if (lastName.isEmpty) {
                print("Enter last Name")
            } else {
                passwordField.becomeFirstResponder()
            }
            
        }
        
        if (textField == passwordField) {
            
            let password = passwordField.text!
            
            if (password.isEmpty) {
                print("valid password")
            } else {
                passwordField.resignFirstResponder()
            }
            
        }
        
        
        return true
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

extension String {
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}

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

class SignUpPageViewController: UIViewController,UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate


    @IBOutlet weak var userLogo: UIImageView!    
    @IBOutlet weak var cyrusTalkLabel: UILabel!
    
    
    @IBOutlet weak var schoolEmailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
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
        
        if (schoolEmailField.text!.isEmpty || passwordField.text!.isEmpty || firstNameField.text!.isEmpty || lastNameField.text!.isEmpty) {
            
            print ("Please fill the empty field above")
            
        } else {
            
                appDelegate.userFire.createUser(schoolEmailField.text!, password: passwordField.text!,
                withValueCompletionBlock: { error, result in
                    if error != nil {
                        // There was an error creating the account
                    } else {
                        let uid = result["uid"] as? String
                        print("Successfully created user account with uid: \(uid)")
                    }
            })
            
        }
        
        
        
        
        
        
        
        
        
    }
    
    
    
    // MARK: - TextField Delegate 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == schoolEmailField) {
            
            let enteredWord = schoolEmailField.text!
            
            if (!enteredWord.contains("@") || enteredWord.isEmpty) {
                
                print("Invalid Input")
                
            } else {
                firstNameField.becomeFirstResponder()
                
            }
            
        }
        
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

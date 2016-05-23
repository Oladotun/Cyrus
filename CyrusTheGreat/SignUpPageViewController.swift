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

class SignUpPageViewController: UIViewController,UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var userLogo: UIImageView!    
    @IBOutlet weak var cyrusTalkLabel: UILabel!
    
    @IBOutlet weak var fieldPicker: UIPickerView!
    
    @IBOutlet weak var schoolEmailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var schoolName:String!
    var studyField:String!
    
    let pickerDataSource = ["Business","Engineering","Education","Natural Science","Arts","Social Science","Computer Science","Medicine","Law","Humanities","Social Work","Education"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLogo.image = UIImage(named:"cyrus")
        cyrusTalkLabel.textAlignment = NSTextAlignment.Left
        
        schoolEmailField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        passwordField.delegate = self
        fieldPicker.delegate = self
        fieldPicker.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
     

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        studyField = pickerDataSource[row]
    }
    
    

    @IBAction func nextButton(sender: AnyObject) {
        
        if (schoolEmailField.text!.isEmpty || passwordField.text!.isEmpty || firstNameField.text!.isEmpty || lastNameField.text!.isEmpty ) { // || passwordField.text!.isEmpty || firstNameField.text!.isEmpty || lastNameField.text!.isEmpty
            
//            print ("Please fill the empty field above")
            
            cyrusTalkLabel.text = "Empty field detected, Kindly fill it up."
            cyrusTalkLabel.textColor = UIColor.redColor()
            cyrusTalkLabel.textAlignment = NSTextAlignment.Left
            
        } else {
            
            print(schoolEmailField.text!)
            if (checkEmailDomain(getDomainFromEmail(schoolEmailField.text!))) {
                appDelegate.userFire.createUser(schoolEmailField.text!, password: passwordField.text!,
                    withValueCompletionBlock: { error, result in
                        if error != nil {
                            // There was an error creating the account
                            print(error)
                        } else {

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
                                        "school_name": self.schoolName,
                                        "field_study": self.studyField
                                    ]
                                    // Create a child path with a key set to the uid underneath the "users" node
                                    // This creates a URL path like the following:
                                    //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                                    self.appDelegate.userFire.childByAppendingPath("users")
                                        .childByAppendingPath(authData.uid).setValue(newUser)
                                    self.performSegueWithIdentifier("connectTwitter", sender: self)

                                }

                                
                                
                                
                            })
   
                        }
                })
                
            } else {
                
//                print ("wrong usa student domain")
                cyrusTalkLabel.text = "Wrong Student Domain, Re-enter."
                cyrusTalkLabel.textColor = UIColor.redColor()
                cyrusTalkLabel.textAlignment = NSTextAlignment.Left

                
                
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
                textField.errorHighlightTextField("School Name is required")
                
            } else {
                textField.removeErrorHighlightTextField()
                firstNameField.becomeFirstResponder()
                
            }

            
        }  
        if (textField == firstNameField) {
            let firstName = firstNameField.text!
            if (firstName.isEmpty) {
                textField.errorHighlightTextField("First Name is required")
            } else {
                textField.removeErrorHighlightTextField()
                lastNameField.becomeFirstResponder()
            }
        }
        
        if (textField == lastNameField) {
            let lastName = lastNameField.text!
            if (lastName.isEmpty) {
                textField.errorHighlightTextField("Last Name is required")
            } else {
                 textField.removeErrorHighlightTextField()
                passwordField.becomeFirstResponder()
            }
            
        }
        
        if (textField == passwordField) {
            let password = passwordField.text!
            if (password.isEmpty) {
                textField.errorHighlightTextField("Password is required")
            } else {
                textField.removeErrorHighlightTextField()
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
extension UITextField {
    
    // Text Field is empty - show red border
    func errorHighlightTextField(msg: String){
        self.layer.borderColor = UIColor.redColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.placeholder = msg
    }
    
    // Text Field is NOT empty - show gray border with 0 border width
    func removeErrorHighlightTextField(){
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 5
    }
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

//
//  ApiConnectorViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/2/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase

class ApiConnectorViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cyrusPrompt: UILabel!
    @IBOutlet weak var cyrusLogo: UIImageView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cyrusLogo.image = UIImage(named:"cyrus")
        cyrusPrompt.text = "Some more information about you..."
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loadProfilePicture(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.contentMode = .ScaleAspectFit
            profilePicture.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func connectToTwitter(sender: AnyObject) {
        if (profilePicture == nil ) {
            cyrusPrompt.text = "Kindly upload a profile picture"
        } else {
            
            if (profilePicture.image == nil) {
                 cyrusPrompt.text = "Kindly upload a profile picture"
                
            } else {
                
                let imageData = UIImageJPEGRepresentation(profilePicture.image!, 2.0)! as NSData
                let str = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                
//                profilePicture.image = str.stringToImage()
//             
                let userImage = ["image": str]
                print(appDelegate.userFire.URL)
                
               FIRDatabase.database().referenceFromURL("https://cyrusthegreat.firebaseio.com/users/\(appDelegate.userIdentifier)/").updateChildValues(userImage)
//                self.appDelegate.userFire.database.referenceWithPath("users").database.referenceWithPath(appDelegate.userIdentifier).updateChildValues(userImage)
//                
////                    childByAppendingPath("users")
////                    .childByAppendingPath(appDelegate.userIdentifier).updateChildValues(userImage)
                self.performSegueWithIdentifier("TwitterInferPage", sender: self)
                
            }
            
            
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

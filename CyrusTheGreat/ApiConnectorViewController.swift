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
    var buttonPressed = false
    
    let imagePicker = UIImagePickerController()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    // Utilizing firebase storage
    let storage = FIRStorage.storage()
    
    
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
        
        if (!buttonPressed) {
            if (profilePicture == nil ) {
                cyrusPrompt.text = "Kindly upload a profile picture"
            } else {
                
                if (profilePicture.image == nil) {
//                    cyrusPrompt.text = "Kindly upload a profile picture"
                    alertView("Kindly upload a profile picture")
                    
                } else {
                    buttonPressed = true
                    let storageRef = storage.referenceForURL("gs://project-5582715640635114460.appspot.com")
//                    print("I am uploading picture")
                    
                    let imageData = UIImageJPEGRepresentation(profilePicture.image!, 2.0)! as NSData
                    let imageInfo = storageRef.child("\(appDelegate.userIdentifier).jpg")
                    
                    // Upload the file to the path "images/rivers.jpg"
                    let _ = imageInfo.putData(imageData, metadata: nil) { metadata, error in
                        if (error != nil) {
                            // Uh-oh, an error occurred!
                            print("we have a problem")
                        } else {
                            // Metadata contains file metadata such as size, content-type, and download URL.
                            let imageInfoPath = imageInfo.fullPath
                            let userImage = ["image": "\(imageInfoPath)"]
                            FIRDatabase.database().referenceFromURL("https://cyrusthegreat.firebaseio.com/users/\(self.appDelegate.userIdentifier)/").updateChildValues(userImage)
                        }
                    }
                    self.performSegueWithIdentifier("TwitterInferPage", sender: self)
                    
                    
                    
                }
                
                
            }
            
        }else {
            alertView(("Uploading images online, just a few more moment"))
        }
        
    }
    
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    
//    }
    
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
    
    

}

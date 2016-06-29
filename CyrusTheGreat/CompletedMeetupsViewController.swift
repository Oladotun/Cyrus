//
//  CompletedMeetupsViewController.swift
//  Cyrus
//
//  Created by Dotun Opasina on 6/28/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit

class CompletedMeetupsViewController: UIViewController, CompletedMeetupDelegate {

    @IBOutlet weak var meetList: UITableView!
//    let list = ["","",""]
    var meetUpList: [[String:String]]!
    var contactInfo:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        meetList.delegate = self
        meetList.dataSource = self
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("goHome", sender: self)
    }
    
    func presentContact(tag:Int){
        
        contactInfo = meetUpList[tag]["Email"]
//        meetList.indexPathForRowAtPoint(<#T##point: CGPoint##CGPoint#>)
        
        let alert = UIAlertController(title:"",message: "Contact: \(contactInfo)", preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(doneAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
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

extension CompletedMeetupsViewController:  UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return meetUpList.count
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let indexPath = tableView.indexPathForSelectedRow!
//        
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = meetList.dequeueReusableCellWithIdentifier("MeetUpCell")! as! CompletedMeetUpsTableViewCell
        cell.name.text = meetUpList[indexPath.row]["Name"]
//        cell.textLabel?.text = meetUpList[indexPath.row]["Name"]
        cell.delegate = self
        cell.contactViewButton.tag = indexPath.row
        
        return cell
    }
}



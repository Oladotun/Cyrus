//
//  HomePageViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/1/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    @IBOutlet weak var currAvailability: UILabel!
    @IBOutlet weak var availSwitch: UISwitch!
    
    @IBOutlet weak var interestCollected: UILabel!
    var interests: [String]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        availSwitch.setOn(false, animated:true)
        currAvailability.text = "Offline"
        availSwitch.addTarget(self, action: Selector("switched:"), forControlEvents: UIControlEvents.ValueChanged)
        
        if interests.count > 0 {
            
            self.interestCollected.text = (interests.joinWithSeparator(","))
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switched(switchState: UISwitch) {
        if switchState.on {
            currAvailability.text = "Online"
        } else {
            currAvailability.text = "Offline"
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

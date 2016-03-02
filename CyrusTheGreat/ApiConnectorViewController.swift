//
//  ApiConnectorViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/2/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit

class ApiConnectorViewController: UIViewController {

    @IBOutlet weak var cyrusPrompt: UILabel!
    @IBOutlet weak var cyrusLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cyrusLogo.image = UIImage(named:"cyrus")
        cyrusPrompt.text = "Trust me, I can infer your interest"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

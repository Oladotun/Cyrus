//
//  CompletedMeetUpsTableViewCell.swift
//  Cyrus
//
//  Created by Dotun Opasina on 6/28/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit

protocol CompletedMeetupDelegate {
    func presentContact(tag:Int)
}

class CompletedMeetUpsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactViewButton: UIButton!
    @IBOutlet weak var name: UILabel!
    var delegate:CompletedMeetupDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func ViewContact(sender: AnyObject) {
        delegate?.presentContact(contactViewButton.tag)
    }

}

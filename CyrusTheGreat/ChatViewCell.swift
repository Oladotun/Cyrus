//
//  ChatViewCell.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/14/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit

protocol ChatViewDelegate {
    func yesTapped()
    func noTapped()
}

class ChatViewCell: UITableViewCell {
    
    var chatViewProtocol: ChatViewDelegate?

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBAction func acceptedInfo(sender: AnyObject) {
        chatViewProtocol?.yesTapped()
    }
    
   
    @IBAction func declinedInfo(sender: AnyObject) {
        chatViewProtocol?.noTapped()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

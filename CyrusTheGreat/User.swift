//
//  User.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/12/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import CoreLocation

class User: NSObject {
    var userId:String!
    var email:String!
    var firstName:String!
    var lastName:String!
    var schoolName:String!
    var userField:String!
    var location:CLLocation!
    var interests:[String]!
    var status:String! 
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

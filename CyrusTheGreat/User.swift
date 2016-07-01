//
//  User.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/12/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import CoreLocation

class User: NSObject,NSCoding {
    var userId:String!
    var email:String!
    var firstName:String!
    var lastName:String!
    var schoolName:String!
    var userField:String!
    var location:CLLocation!
    var interests:[String]!
    var status:String!
    
    required init(coder aDecoder: NSCoder) {
        userId = aDecoder.decodeObjectForKey("currUserId") as! String
        email = aDecoder.decodeObjectForKey("email") as! String
        firstName = aDecoder.decodeObjectForKey("firstName") as! String
        lastName = aDecoder.decodeObjectForKey("lastName") as! String
        schoolName = aDecoder.decodeObjectForKey("schoolName") as! String
        userField = aDecoder.decodeObjectForKey("userField") as! String
        location = aDecoder.decodeObjectForKey("location") as! CLLocation
        interests = aDecoder.decodeObjectForKey("interests") as! [String]
        status = aDecoder.decodeObjectForKey("status") as! String

        
    }
    override init() {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userId, forKey: "currUserId")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(firstName, forKey: "firstName")
        aCoder.encodeObject(lastName,forKey:"lastName")
        aCoder.encodeObject(schoolName, forKey: "schoolName")
        aCoder.encodeObject(userField, forKey: "userField")
        aCoder.encodeObject(location, forKey: "location")
        aCoder.encodeObject(interests,forKey:"interests")
        aCoder.encodeObject(status,forKey:"status")
    }
    
    
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

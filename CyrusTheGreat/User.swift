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
        super.init()
        if let userId = aDecoder.decodeObjectForKey("currUserId")  {
            self.userId = userId as! String
        }
        if let email = aDecoder.decodeObjectForKey("email")  {
            self.email = email as! String
        }
        
        if let firstName = aDecoder.decodeObjectForKey("firstName") {
            self.firstName = firstName as! String
        }
        if let lastName = aDecoder.decodeObjectForKey("lastName") {
            self.lastName = lastName as! String
        }
        if let schoolName = aDecoder.decodeObjectForKey("schoolName") {
            self.schoolName = schoolName as! String
        }
        if let userField = aDecoder.decodeObjectForKey("userField") {
            self.userField = userField as! String
        }
        
        if let location = aDecoder.decodeObjectForKey("location") {
            self.location = location as! CLLocation
        }
        if let interests = aDecoder.decodeObjectForKey("interests") {
            self.interests = interests as! [String]
        }
        if let status = aDecoder.decodeObjectForKey("status") {
            self.status = status as! String
        }

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

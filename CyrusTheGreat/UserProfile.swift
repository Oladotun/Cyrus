//
//  UserProfile.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/12/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit

class UserProfile:NSObject,NSCoding {
    var user:User!
    var userDistance:Double!
    var userMatchedInterest:[String]!
    var userMatchedCount:Int!
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        if let user = aDecoder.decodeObjectForKey("madeUser") {
            self.user = user as! User
        }
       
        userDistance = aDecoder.decodeDoubleForKey("userDistance")
        if let userMatchedInterest = aDecoder.decodeObjectForKey("matchedInterests")  {
            self.userMatchedInterest = userMatchedInterest as! [String]
        }
        if let userCount = aDecoder.decodeObjectForKey("matchedCounts") {
            userMatchedCount = userCount as! Int
        }
        
        
    }
    override init() {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(user, forKey: "madeUser")
        aCoder.encodeDouble(userDistance, forKey: "userDistance")
        aCoder.encodeObject(userMatchedInterest, forKey: "matchedInterests")
        aCoder.encodeObject(userMatchedCount, forKey: "matchedCounts")
    }
    
}


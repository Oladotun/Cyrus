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
        
        user = aDecoder.decodeObjectForKey("madeUser") as! User
        userDistance = aDecoder.decodeDoubleForKey("userDistance")
        userMatchedInterest = aDecoder.decodeObjectForKey("matchedInterests") as! [String]
        userMatchedCount = aDecoder.decodeObjectForKey("userMatchedCount") as! Int
        
    }
    override init() {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(user, forKey: "madeUser")
        aCoder.encodeObject(userDistance, forKey: "userDistance")
        aCoder.encodeObject(userMatchedInterest, forKey: "matchedInterests")
        aCoder.encodeObject(userMatchedCount, forKey: "matchedCounts")
    }
    
}


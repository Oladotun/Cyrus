//
//  firebaseMeetUpInfoManager.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/12/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase
protocol FirebaseMeetUpInfoManagerDelegate {
    
    func segueToNext()
    func alertOtherUserArrival()
    
}

class FirebaseMeetUpInfoManager: NSObject {
    
    var meetUpPathWay:Firebase!
    var segueToQuestionNode:Firebase!
    var delegate:FirebaseMeetUpInfoManagerDelegate?
    var userId:String!
    var questionTime:Bool!
    
    init(meetPath:Firebase,myId:String) {
        super.init()
        meetUpPathWay = meetPath
        segueToQuestionNode = meetUpPathWay.childByAppendingPath("segueToQuestion")
        userId = myId
        observeNextQuestionNode()
    }
    
    func observeNextQuestionNode() {
        
        segueToQuestionNode.observeEventType(.Value, withBlock: {
            snapshot in
            
            for child in snapshot.children {
                if (child.key != self.userId) {
                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    
                    if let readyQuest = childSnapshot.value as? Bool {
                        
                        if (readyQuest == true && self.questionTime == true) {
                            
                            self.delegate?.segueToNext()
                        } else {
                            self.delegate?.alertOtherUserArrival()
                        }
                    }
                }
            }
        })
        
    }

}

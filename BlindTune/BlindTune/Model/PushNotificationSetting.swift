//
//  SwitchNotificationSetting.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 21/03/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit

class PushNotificationSetting: NSObject {
    
    var commentOnMyPost: Bool
    var nezzUpdate: Bool
    var allPost: Bool
    var userId: String
   
    
    init(commentOnMyPost: Bool, nezzUpdate: Bool, allPost : Bool, userId: String) {
        self.commentOnMyPost = commentOnMyPost
        self.nezzUpdate = nezzUpdate
        self.allPost = allPost
        self.userId = userId
    }
    
    func toAnyObject() -> Any {
        return [
            "commentOnMyPost": commentOnMyPost,
            "nezzUpdate": nezzUpdate,
            "allPost": allPost,
            "userId": userId
        ]
    }
}

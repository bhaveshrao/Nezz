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
    var _id: String
   
    
    init(commentOnMyPost: Bool, nezzUpdate: Bool, allPost : Bool, _id: String) {
        self.commentOnMyPost = commentOnMyPost
        self.nezzUpdate = nezzUpdate
        self.allPost = allPost
        self._id = _id
    }
    
    func toAnyObject() -> Any {
        return [
            "commentOnMyPost": commentOnMyPost,
            "nezzUpdate": nezzUpdate,
            "allPost": allPost,
            "_id": _id
        ]
    }
}

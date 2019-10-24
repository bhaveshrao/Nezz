//
//  ReplyOnPost.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 18/02/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit

class ReplyOnPost: NSObject {

    let replyTo: String
    let replyBy: String
    let audioTitle: String
    let audioName :String
    let audioURL :String
    let timeCreated :Double
    let timeDuration : String
    let postId : String
    let username:String
    let replyType:String
    let text:String
    let notificationType:String
    
    init(replyTo: String, replyBy: String, audioTitle: String, audioName: String, audioURL: String, timeCreated : Double, timeDuration:String, postId: String, username:String,replyType:String,text:String, notificationType:String) {
        self.replyTo = replyTo
        self.replyBy = replyBy
        self.audioTitle = audioTitle
        self.audioName = audioName
        self.audioURL = audioURL
        self.timeCreated = timeCreated
        self.timeDuration = timeDuration
        self.postId = postId
        self.username = username
        self.replyType = replyType
        self.text = text
        self.notificationType = notificationType
    }
    
    func toAnyObject() -> Any {
        return [
            "replyTo": replyTo,
            "replyBy": replyBy,
            "audioTitle": audioTitle,
            "audioName": audioName,
            "audioURL": audioURL,
            "timeCreated" :timeCreated,
            "timeDuration" : timeDuration,
            "postId" : postId,
            "username" : username,
            "replyType":replyType,
            "text":text,
            "notificationType":notificationType
        ]
    }
}

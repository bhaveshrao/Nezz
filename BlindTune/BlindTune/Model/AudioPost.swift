//
//  AudioPost.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 07/02/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit

struct AudioPost {
    
    let userID: String
    let audioTitle: String
    let audioName :String
    let audioURL :String
    let username:String
    let timeCreated :Double
    let timeDuration : String
    let postId : String
    let commentCount : Int
    
    init(userID: String, audioTitle: String, audioName: String, audioURL: String, username:String, timeCreated : Double, timeDuration:String, postId: String , commentCount : Int) {
        self.userID = userID
        self.audioTitle = audioTitle
        self.audioName = audioName
        self.audioURL = audioURL
        self.username = username
        self.timeCreated = timeCreated
        self.timeDuration = timeDuration
        self.postId = postId
        self.commentCount = commentCount
    }
    
    func toAnyObject() -> Any {
        return [
            "userID": userID,
            "audioTitle": audioTitle,
            "audioName": audioName,
            "audioURL": audioURL,
            "username" : username,
            "timeCreated" :timeCreated,
            "timeDuration" : timeDuration,
            "postId" : postId,
            "commentCount" : commentCount
        ]
    }
    
}

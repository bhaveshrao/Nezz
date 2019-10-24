/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Firebase

class User:NSObject, NSCoding{
  
  let uid: String
  let email: String
  let username :String
    let deviceId : String
    
  init(authData: Firebase.User) {
    uid = authData.uid
    email = authData.email!
    username = authData.displayName!
    deviceId = Messaging.messaging().fcmToken!
  }
  
    init(uid: String, email: String, username: String) {
    self.uid = uid
    self.email = email
    self.username = username
    self.deviceId = Messaging.messaging().fcmToken!

  }
    
    func toAnyObject() -> Any {
        return [
            "email": email,
            "password": "",
            "username": username,
            "deviceId": Messaging.messaging().fcmToken!,
            "uid" : uid
        ]
    }
    
    required init(coder decoder: NSCoder) {
        self.uid = decoder.decodeObject(forKey: "uid") as? String ?? ""
        self.email =  decoder.decodeObject(forKey: "email") as? String ?? ""
         self.username =  decoder.decodeObject(forKey: "username") as? String ?? ""
         self.deviceId =  decoder.decodeObject(forKey: "deviceId") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(uid, forKey: "uid")
        coder.encode(email, forKey: "email")
        coder.encode(username, forKey: "username")
        coder.encode(deviceId, forKey: "deviceId")
        }
    
//    required init(coder decoder: NSCoder) {
//        self.uid = decoder.decodeObject(forKey: "uid") as? String ?? ""
//        self.email =
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(name, forKey: "name")
//        coder.encode(age, forKey: "age")
//    }
    
}

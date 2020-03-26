////
////  NotificationViewController.swift
////  BlindTune
////
////  Created by Rao, Bhavesh (external - Project) on 27/01/19.
////  Copyright © 2019 Bhavesh Rao. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class  NotificationTableViewCell: UITableViewCell {
//    @IBOutlet weak var labelName: UILabel!
//    @IBOutlet weak var labelAdditionalText: UILabel!
//    @IBOutlet weak var labelTimeDetail: UILabel!
//    
//}
//
//
//class NotificationViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource{
//   
//    @IBOutlet weak var tableView: UITableView!
//    let dataBaseRefReplyPost = Database.database().reference(withPath: "ReplyOnPost")
//    let dataBaseRefUsers = Database.database().reference(withPath: "Users")
//
//    var audioReplyPostArray = [Dictionary<String, Any>]()
//    var usersArray = [Dictionary<String, Any>]()
//    var notificationArray = [Dictionary<String, Any>]()
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.tableFooterView = UIView()
//        self.getUsers()
//        
//        // Do any additional setup after loading the view.
//    }
//    
////    func getReplyPostList(){
////        dataBaseRefReplyPost.observe(.value) { (snapshot) in
////
//////            self.indicatorContainerView.isHidden = true
//////            self.activityIndicator.stopAnimating()
//////
////
////            if let tempArray = snapshot.value as? [String:Any] {
////                self.audioReplyPostArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
////            }
////
////            self.notificationArray = self.audioReplyPostArray.filter({ (replyOnPost) -> Bool in
////                replyOnPost["replyTo"] as! String == AppDelegate.user._id
////            self.notificationArray = self.notificationArray.sorted(by: { (value1, value2) -> Bool in
////                TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
////            })
////
////            self.tableView.reloadData()
////
////        }
////    }
//}
//    
////    func getUsers(){
////        dataBaseRefUsers.observe(.value) { (snapshot) in
////            if let tempArray = snapshot.value as? [String:Any] {
////                self.usersArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
////            }
////            if !(self.usersArray.isEmpty){
////                self.getReplyPostList()
////            }
////        }
////    }
//    
//    func getUserName(byId:String) -> String{
//        
//        if byId == AppDelegate.user._id {
//            return "You"
//        }
//        
//        let tempArray = self.usersArray.filter { (user) -> Bool in
//            user["uid"] as! String == byId
//        }
//        let value = tempArray.last
//        return value!["username"] as! String
//    }
//    
//    @IBAction func backButtonClicked(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return notificationArray.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let tableCell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationTableViewCell
//        
//        let notificationValue = self.notificationArray[indexPath.row]
//        tableCell.labelName.text = getUserName(byId: notificationValue["replyBy"] as! String)
//        
//        let date1 = Date()
//        let date2 = Date(timeIntervalSince1970: notificationValue["timeCreated"] as! Double )
//            // 3:30
//        
//        let diff = Int(date1.timeIntervalSince(date2))
//        
//        var hours = diff / 3600
//        var minutes = (hours * 3600 - diff) / 60
//        var days = hours/24
//        
//        hours = abs(hours)
//        minutes = abs(minutes)
//        days = abs(days)
//
//        if days > 0{
//            if days == 1 {
//                tableCell.labelTimeDetail.text = "\(days) day ago"
//            }else{
//                tableCell.labelTimeDetail.text = "\(days) days ago"
//            }
//        }else
//        if hours > 0 {
//            if hours == 1{
//                tableCell.labelTimeDetail.text = "\(hours) hour ago"
//            }else{
//                tableCell.labelTimeDetail.text = "\(hours) hours ago"
//            }
//        }else if  minutes > 0 {
//            
//            if minutes == 1{
//                tableCell.labelTimeDetail.text = "\(minutes) minute ago"
//            }else{
//                tableCell.labelTimeDetail.text = "\(minutes) minutes ago"
//            }
//        }else{
//            tableCell.labelTimeDetail.text = "Now"
//        }
//        
//        tableCell.selectionStyle = .none
//        
//        return tableCell
//    }
//    
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(notificationArray[indexPath.row])
//        
//        let selectedDic = notificationArray[indexPath.row]
//        
//        let tempArray = self.audioReplyPostArray.filter { (tempDic) -> Bool in
//                     let array = (selectedDic["postId"] as! String).components(separatedBy: ".")
//                   return tempDic["postId"] as! String == array.first!
//        }
//        
//        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
//             controller.commentArray = tempArray
//             controller.audioPostDic = selectedDic
//        self.navigationController?.pushViewController(controller, animated: true)
//        
//    }
//
//}

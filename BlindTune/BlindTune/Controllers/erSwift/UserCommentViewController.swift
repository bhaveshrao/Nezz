//
//  UserCommentViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 10/07/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

//
//  CommentViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 27/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase
import GrowingTextView
import Firebase

class UserCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    var commentArray = [Dictionary<String, Any>]()
    @IBOutlet weak var commentViewCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: GrowingTextView!
    @IBOutlet weak var sendButton: UIButton!
    let firebaseRefReply = Database.database().reference(withPath: "ReplyOnPost")
    
    var audioPostDic = Dictionary<String, Any>()
    var allCommentArray = [Dictionary<String, Any>]()
    var timer:Timer!
    var lastPlayedIndex = -1
    var selectedIndex = -1
    var userIdSet = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(commentArray)
        
        automaticallyAdjustsScrollViewInsets = false
        self.sendButton.isEnabled = false
        
        commentTextView.text = "Type your comment here..."
        commentTextView.textColor = UIColor.lightGray
        commentTextView.delegate = self
        
        
        if commentArray.isEmpty {
            
            let alertVC = UIAlertController(title: "", message: "There are no comments on this Thread", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                (_) in
                self.navigationController?.popViewController(animated: true)
            }
            
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
        }
        
        
        self.getReplyPostList()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
//
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (time) in
            self.getReplyPostList()
        }

        self.commentArray.reverse()
        self.tableView.reloadData()
        
        if !(commentArray.isEmpty ) {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.commentArray.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }

        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
            tempAudioPlayer.stop()
        }
        AppDelegate.currentAudioPlayer.removeAll()
        
        timer.invalidate()
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
            tempAudioPlayer.stop()
        }
        AppDelegate.currentAudioPlayer.removeAll()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
            
            if self.containerTextViewBottomConstraint.constant == 10 {
                
                self.containerTextViewBottomConstraint.constant =
                    self.containerTextViewBottomConstraint.constant + keyboardSize.height
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.containerTextViewBottomConstraint.constant = 10
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func audioButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        var postDic = self.audioPostDic
        postDic["userID"] = self.audioPostDic["replyBy"]
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplyViewController") as! ReplyViewController
        controller.audioPostDic = postDic
        controller.isFromCommentController = true
        controller.userIdSet = self.userIdSet
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.handleTextReplySendWith(message: commentTextView.text)
        
    }
    
    @objc func moreButtonClicked(sender:UIButton)
    {
        
        let selectedDic = commentArray[sender.tag]
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReportCommentViewController") as!
        ReportCommentViewController
        controller.selectedDic = selectedDic
        controller.prevController = "userComment"

        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func playButtonClicked(sender:UIButton)
    {
        
        selectedIndex = sender.tag
        if lastPlayedIndex != sender.tag {
            
            if lastPlayedIndex != -1 {
                let indexPath = IndexPath(item: lastPlayedIndex, section: 0)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            lastPlayedIndex = sender.tag
        }
    }
    
    @objc func replyButtonClicked(sender:UIButton)
    {
        
       
        
        //        selectedIndex = sender.tag
        //        if lastPlayedIndex != sender.tag {
        //
        //            if lastPlayedIndex != -1 {
        //                let indexPath = IndexPath(item: lastPlayedIndex, section: 0)
        //                tableView.reloadRows(at: [indexPath], with: .none)
        //            }
        //            lastPlayedIndex = sender.tag
        //        }
    }
    
    @objc func usrerCountButtonClicked(sender:UIButton)
    {
        
        //        selectedIndex = sender.tag
        //        if lastPlayedIndex != sender.tag {
        //
        //            if lastPlayedIndex != -1 {
        //                let indexPath = IndexPath(item: lastPlayedIndex, section: 0)
        //                tableView.reloadRows(at: [indexPath], with: .none)
        //            }
        //            lastPlayedIndex = sender.tag
        //        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let audioTableCell = tableView.dequeueReusableCell(withIdentifier: "audioUserCommentCell") as! AudioUserCommentTableViewCell
        let textTableCell = tableView.dequeueReusableCell(withIdentifier: "textUserCommentCell") as! TextUserCommentTableViewCell
        
        let tempDic = self.commentArray[indexPath.row]
        
        if (tempDic["replyType"] as! String) == "audio"{
            
            audioTableCell.labelAudioTitle.text = "Reply by " + (tempDic["username"] as! String)
            audioTableCell.url = (tempDic["audioURL"]! as! String)
            audioTableCell.audioLastTimeLabel.text = (tempDic["timeDuration"] as! String)
            
            audioTableCell.audioPlayer = nil
            audioTableCell.audioSlider.value = 0
            audioTableCell.audioCurrentTimeLabel.text = "0:00"
            audioTableCell.imageWidthConstraint.constant = 0
            audioTableCell.playButton.isSelected = false
            audioTableCell.timer?.invalidate()
            
            
            
            let tempArray = (tempDic["audioName"] as! String).components(separatedBy: ".")
            audioTableCell.userButton.setTitle("\(getUserCountBy(postId:tempArray.first!))", for: .normal)
            
            audioTableCell.moreButton.addTarget(self, action:#selector(CommentViewController.moreButtonClicked(sender:)) , for: .touchUpInside)
            audioTableCell.playButton.addTarget(self, action:#selector(CommentViewController.playButtonClicked(sender:)) , for: .touchUpInside)
            audioTableCell.replyButton.addTarget(self, action:#selector(CommentViewController.replyButtonClicked(sender:)) , for: .touchUpInside)
            audioTableCell.userButton.addTarget(self, action:#selector(CommentViewController.usrerCountButtonClicked(sender:)) , for: .touchUpInside)
            
            audioTableCell.userButton.isHidden = true
            audioTableCell.playButton.tag = indexPath.row
            audioTableCell.moreButton.tag = indexPath.row
            audioTableCell.replyButton.tag = indexPath.row
            audioTableCell.userButton.tag = indexPath.row
            
            return audioTableCell
        }else{
            textTableCell.labelAudioTitle.text = "Reply by " + (tempDic["username"] as! String)
            textTableCell.labelTextReply.text = (tempDic["text"] as! String)
            
            textTableCell.moreButton.tag = indexPath.row
            textTableCell.replyButton.tag = indexPath.row
            textTableCell.userCountButton.tag = indexPath.row
            textTableCell.userCountButton.isHidden = true
            
            
            let tempArray = (tempDic["audioName"] as! String).components(separatedBy: ".")
            textTableCell.userCountButton.setTitle("\(getUserCountBy(postId:tempArray.first!))", for: .normal)
            
            textTableCell.moreButton.addTarget(self, action:#selector(CommentViewController.moreButtonClicked(sender:)) , for: .touchUpInside)
            
            textTableCell.replyButton.addTarget(self, action:#selector(CommentViewController.replyButtonClicked(sender:)) , for: .touchUpInside)
            textTableCell.userCountButton.addTarget(self, action:#selector(CommentViewController.usrerCountButtonClicked(sender:)) , for: .touchUpInside)
            
            return textTableCell
            
        }
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let tempDic = self.commentArray[indexPath.row]
        if (tempDic["replyType"] as! String) == "audio"{
            return 160
        }else{
            return 106
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tempDic = self.commentArray[indexPath.row]
        
        if (tempDic["replyType"] as! String) == "audio"{
            return 160
        }else{
            return UITableView.automaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == selectedIndex {
            AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
                tempAudioPlayer.stop()
            }
            AppDelegate.currentAudioPlayer.removeAll()
        }
    }
    
    
    
    
    
    func handleTextReplySendWith(message: String) {
        
        let randomeInt = Int.random(in: 500...50000)
        let fileName = AppDelegate.user._id + String(format: "%d", randomeInt)
        
       let tempArray =  (self.audioPostDic["audioName"] as! String).components(separatedBy: ".")

        
        let audioReplyPost = ReplyOnPost(replyTo: self.audioPostDic["replyBy"] as! String, replyBy: AppDelegate.user._id, audioTitle: self.audioPostDic["audioTitle"] as! String, audioName: fileName , audioURL: "",
                                         timeCreated: Date().timeIntervalSince1970, timeDuration: "", postId: tempArray[0],  username: AppDelegate.user.username, replyType: "text", text: message, notificationType: "userComment")
        
        self.commentArray.append(audioReplyPost.toAnyObject() as! [String : Any])
        self.commentArray = self.commentArray.sorted(by: { (value1, value2) -> Bool in
            TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
        })
        
        self.firebaseRefReply.child(fileName).setValue(audioReplyPost.toAnyObject())
        
        var arrayUserId =  [String](self.userIdSet)
        if !(arrayUserId.contains(self.audioPostDic["replyBy"] as! String) ){
            arrayUserId.append(self.audioPostDic["replyBy"] as! String)
        }
        self.callForPushNotification(userId: arrayUserId)
        
        
        commentTextView.text = "Type your comment here..."
        commentTextView.textColor = UIColor.lightGray
        commentTextView.resignFirstResponder()
        
        self.commentArray.reverse()
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                let indexPath = IndexPath(row: self.commentArray.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        
        
        //        storageRef.child(fileName).
    }
    
    func callForPushNotification(userId: [String]) {
        let session = URLSession.shared
        let url = URL(string: "http://104.248.118.154:3000/api/sendnotificationbyid")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let json = [
            "title": "TooDeep",
            "message": AppDelegate.user.username + " has commented on your post",
            "userkeyArr" :userId,
            "commentedBy" : AppDelegate.user._id,
            "notificationType" : "userComment",
            "postId" : self.audioPostDic["postId"] as! String
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
        }
        task.resume()
    }
    
    
}

extension UserCommentViewController : GrowingTextViewDelegate{
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.sendButton.isEnabled = false
        }else{
            self.sendButton.isEnabled = true
            
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        
        if textView.text.isEmpty {
            textView.text = "Type your comment here..."
            textView.textColor = UIColor.lightGray
            self.sendButton.isEnabled = false
        } else{
            self.sendButton.isEnabled = true
            
        }
    }
    
    
    @objc func getUserCountBy(postId:String) -> Int{
        
        let tempArray = self.allCommentArray.filter { (tempDic) -> Bool in
            tempDic["postId"] as! String == postId
        }
        var tempArrayForUser = [String]()
        tempArray.forEach { (dict) in
            tempArrayForUser.append(dict["replyBy"] as! String)
        }
        let tempSet = Set(tempArrayForUser)
        return tempSet.count
    }
    
    
    
    func getReplyPostList(){
        
        
        
        if AppDelegate.currentAudioPlayer.first != nil {
            if !(AppDelegate.currentAudioPlayer.first!.isPlaying) {
                
                firebaseRefReply.observe(.value) { (snapshot) in
                    if let tempArray = snapshot.value as? [String:Any] {
                        self.allCommentArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
                    }
                    
                    if self.allCommentArray.count > self.commentArray.count {
                        
                        let tempStringArray = (self.audioPostDic["audioName"] as! String).components(separatedBy: ".")
                        
                        let tempArray = self.allCommentArray.filter { (tempDic) -> Bool in
                            tempDic["postId"] as! String == tempStringArray[0]
                        }
                        
                        self.commentArray = tempArray.sorted(by: { (value1, value2) -> Bool in
                            TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
                        })
                        
                        self.commentArray.reverse()
                        
                        DispatchQueue.main.async {
                            UIView.performWithoutAnimation {
                                self.tableView.reloadData()
                            }
                        }

                    }
                }
            }
        }else{
            
            firebaseRefReply.observe(.value) { (snapshot) in
                if let tempArray = snapshot.value as? [String:Any] {
                    self.allCommentArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
                }
                
                
                if self.allCommentArray.count > self.commentArray.count {
                    
                    let tempStringArray = (self.audioPostDic["audioName"] as! String).components(separatedBy: ".")
                    
                    let tempArray = self.allCommentArray.filter { (tempDic) -> Bool in
                        tempDic["postId"] as! String == tempStringArray[0]
                    }
                    
                    self.commentArray = tempArray.sorted(by: { (value1, value2) -> Bool in
                        TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
                    })
                    
                    self.commentArray.reverse()
                    
                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadData()
                        }
                    }
                }
                
            }
            
        }
        
        
        
    }
}



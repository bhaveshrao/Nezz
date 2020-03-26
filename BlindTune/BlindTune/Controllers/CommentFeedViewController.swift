//
//  CommentFeedViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 16/03/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit
import Foundation

import GrowingTextView
import NVActivityIndicatorView

class CommentFeedViewController: UIViewController, UITextViewDelegate {
    
    var postDic: Dictionary<String, Any> = [:]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    var replyOnPostArray = [Dictionary<String, Any>]()
    var subCommentArray = [Dictionary<String, Any>]()
    
    var replyTypeString = ""
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicatorMain: NVActivityIndicatorView!
    
    @IBOutlet weak var containerTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: GrowingTextView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.text = "Say something..."
        commentTextView.textColor = UIColor.lightGray
        commentTextView.delegate = self
        
        commentTextView.textColor = UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)
        
        //        textField.attributedPlaceholder = NSAttributedString(string: "Add a title...",
        //                                                             attributes:
        //            [NSAttributedString.Key.foregroundColor:
        //                UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)])
        //        textField.textColor = UIColor.white
        //
        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView()
        
        self.sendButton.setBackgroundImage(UIImage(named: "mic"), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.indicatorContainerView.isHidden = false
        self.activityIndicatorMain.startAnimating()
        
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension;
        self.tableView.estimatedSectionHeaderHeight = 80;
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getAllComment(byID: postDic["_id"] as! String)
        
    }
    
    @IBAction func buttonCommentAction(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if replyTypeString != "subComment" {
            
            
            let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "CommentFeedViewController") as! CommentFeedViewController
            ctrl.postDic = self.replyOnPostArray[button.tag ]
            ctrl.replyTypeString = "subComment"
            self.navigationController?.pushViewController(ctrl, animated: true)
            
        }
        
        
        
        
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
            audioPlayer.stop()
        }
        AppDelegate.currentAudioPlayer.removeAll()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendButtonAction(_ sender: Any) {
        
        self.commentTextView.resignFirstResponder()
        
        if !(self.sendButton.isSelected){
            let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "AudioPostViewController") as! AudioPostViewController
            if self.replyTypeString == "subComment" {
                ctrl.isControllerType = "subComment"
            }else{
                ctrl.isControllerType = "Comment"
            }
            ctrl.postDic  = self.postDic
            self.navigationController?.pushViewController(ctrl, animated: true)
        }else{
            self.indicatorContainerView.isHidden = false
            self.activityIndicatorMain.startAnimating()
            self.commentTextView.resignFirstResponder()
            
            if self.replyTypeString == "subComment" {
                self.submitTextSubComment(byID: postDic["_id"] as! String)
            }else{
                self.submitTextComment()
            }
            
        }
    }
    
    func getAllComment(byID:String){
        
        let headers = [
            "cache-control": "no-cache",
            "postman-token": "1a8e168f-709f-eb06-0b83-d8e52138129f"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: Constant.baseURL + "/replyOnPost/getByPost/" + byID)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                do {
                    let tempArray = try (JSONSerialization.jsonObject(with: data!, options : .allowFragments) as? [Dictionary<String,Any>])!
                    self.replyOnPostArray = tempArray
                    
                    //                    self.replyOnPostArray.forEach { (dictionary) in
                    //                        if let tempArray = dictionary["subComment"] as? [[String : Any]]{
                    //                            if !tempArray.isEmpty {
                    //                                self.subCommentArray.append(tempArray[0])
                    //                                 self.replyOnPostArray.append(tempArray[0])
                    //                            }
                    //                        }
                    //                   }
                    
                    
                    print(tempArray)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.indicatorContainerView.isHidden = true
                        self.activityIndicatorMain.stopAnimating()
                        
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        })
        
        dataTask.resume()
    }
    
    
    func submitTextSubComment(byID:String){
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "9078ecf6-2d0c-54da-21d1-bd84ead7a7e2"
        ]
        let parameters = [
            "subComment": [[
                "audioName": "",
                "audioTitle": "",
                "audioURL": "",
                "postId": postDic["_id"] as! String,
                "replyBy": AppDelegate.user._id,
                "replyTo": postDic["replyBy"] as! String,
                "replyType": "text",
                "text": commentTextView.text!,
                "timeCreated": "\(Date().timeIntervalSince1970)",
                "timeDuration": "",
                "username": AppDelegate.user.username,
                "subComment": []
                ]],
            ] as [String : Any]
        
        
        var postData = Data()
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }catch {
            print(error)
        }
        
        let request = NSMutableURLRequest(url: NSURL(string:Constant.baseURL +  "/replyOnPost/" + byID)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                DispatchQueue.main.async {
                    
                    
                    self.commentTextView.text = "Say something..."
                    self.commentTextView.textColor = UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)
                    
                    
                    let alerController = UIAlertController(title: "Congratulations!!", message: "Your reply has been posted successfully!!", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { (alert) in
                        
                        DispatchQueue.main.async {
                            
                            self.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callHome"), object: nil)
                        }
                        
                    })
                    
                    alerController.addAction(alertAction)
                    self.present(alerController, animated: true, completion: nil)
                    
                    self.indicatorContainerView.isHidden = true
                    self.activityIndicatorMain.stopAnimating()
                }
                
            }
        })
        
        dataTask.resume()
        
    }
    
    func submitTextComment(){
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "1c9bf83e-6ab0-01e9-717d-2c7ade2ac21e"
        ]
        
        let parameters = [
            "audioName": "",
            "audioTitle": "",
            "audioURL": "",
            "postId": postDic["_id"] as! String,
            "replyBy": AppDelegate.user._id,
            "replyTo": postDic["userID"] as! String,
            "replyType": "text",
            "text": commentTextView.text!,
            "timeCreated": "\(Date().timeIntervalSince1970)",
            "timeDuration": "",
            "username": AppDelegate.user.username,
            "subComment": []
            ] as [String : Any]
        
        var postData = Data()
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }catch {
            print(error)
        }
        let request = NSMutableURLRequest(url: NSURL(string: Constant.baseURL + "/replyOnPost/create/")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                DispatchQueue.main.async {
                    
                    
                    self.commentTextView.text = "Say something..."
                    self.commentTextView.textColor = UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)
                    
                    
                    let alerController = UIAlertController(title: "Congratulations!!", message: "Your reply has been posted successfully!!", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { (alert) in
                        
                        DispatchQueue.main.async {
                            
                            self.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callHome"), object: nil)
                        }
                        
                    })
                    
                    alerController.addAction(alertAction)
                    self.present(alerController, animated: true, completion: nil)
                    
                    self.indicatorContainerView.isHidden = true
                    self.activityIndicatorMain.stopAnimating()
                }
                
            }
        })
        
        dataTask.resume()
        
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
            
            if self.containerTextViewBottomConstraint.constant == 3 {
                
                self.containerTextViewBottomConstraint.constant =
                    -( self.containerTextViewBottomConstraint.constant + keyboardSize.height)
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.containerTextViewBottomConstraint.constant = 3
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension CommentFeedViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.replyOnPostArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            var tempTypeString = ""
            
            if let postType = postDic["postType"] as? String  {
                tempTypeString = postType
            }
            
            if let replyType = postDic["replyType"] as? String  {
                tempTypeString = replyType
                
            }
            
            if tempTypeString == "audio" {
                
                if self.replyTypeString == "subComment" {
                    
                    let tableCell = tableView.dequeueReusableCell(withIdentifier: "threadAudioCommentCell") as! ThreadAudioCommentCell
                    
                    tableCell.selectionStyle = .none
                    
                    tableCell.audioTitleLabel.text = (postDic["audioTitle"] as! String)
                    tableCell.usernameLabel.text = (postDic["username"] as! String)
                    tableCell.commentLabel.text = "\(postDic["commentCount"] as! Int)"
                    tableCell.audioSlider.value = 0
                    tableCell.audioPlayer = nil
                    tableCell.sepreatorLabel.isHidden = false
                    tableCell.waveformView.isHidden = true
                    tableCell.clickableButton.isSelected = false
                    tableCell.progressViewConstraint.constant = -(tableCell.waveformView.frame.size.width)
                    tableCell.topThreadLabel.isHidden = true
                    tableCell.clickableButton.tag = section
                    //                tableCell.clickableButton.addTarget(self, action: #selector(clickableTouchUp(sender:)), for: .touchUpInside)
                    //
                    tableCell.timer?.invalidate()
                    tableCell.url = (postDic["audioURL"]! as! String)
                    
                    return tableCell
                }else{
                    
                    //                        let tableCell = tableView.dequeueReusableCell(withIdentifier: "commentAudioCell", for: indexPath) as! CommentAudioTableViewCell
                    
                    let tableCell = tableView.dequeueReusableCell(withIdentifier: "commentAudioCell") as! CommentAudioTableViewCell
                    
                    tableCell.selectionStyle = .none
                    
                    tableCell.audioTitleLabel.text = (postDic["audioTitle"] as! String)
                    tableCell.usernameLabel.text = (postDic["username"] as! String)
                    tableCell.commentLabel.text = "\(postDic["commentCount"] as! Int)"
                    tableCell.audioSlider.value = 0
                    tableCell.audioPlayer = nil
                    tableCell.sepreatorLabel.isHidden = false
                    tableCell.waveformView.isHidden = true
                    tableCell.clickableButton.isSelected = false
                    tableCell.progressViewConstraint.constant = -(tableCell.waveformView.frame.size.width)
                    
                    tableCell.clickableButton.tag = section
                    //                tableCell.clickableButton.addTarget(self, action: #selector(clickableTouchUp(sender:)), for: .touchUpInside)
                    //
                    tableCell.timer?.invalidate()
                    tableCell.url = (postDic["audioURL"]! as! String)
                    
                    return tableCell
                    
                }
                
                
            }else{
                
                if self.replyTypeString == "subComment" {
                    
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "threadTextCommentCell") as! ThreadTextCommentCell
                    
                    
                    let date = Date(timeIntervalSince1970: (postDic["timeCreated"] as! NSString).doubleValue)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                    dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                    dateFormatter.timeZone = .current
                    let localDate = dateFormatter.string(from: date)
                    cell.usernameLabel.text = localDate
                    
                    cell.topThreadLabel.isHidden = true
                    
                    cell.messageLabel.text = (postDic["audioName"] as! String)
                    cell.selectionStyle = .none
                    
                    cell.titleLabel.text = (postDic["text"] as! String)
                    
                    return cell
                    
                    
                }else{
                    
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "commentTextCell") as! CommentTextTableViewCell
                    
                    
                    cell.messageLabel.text = (postDic["audioName"] as! String)
                    cell.selectionStyle = .none
                    //                    cell.commentLabel.text = "\(postDic["commentCount"] as! Int)"
                    //
                    cell.titleLabel.text = (postDic["audioTitle"] as! String)
                    cell.usernameLabel.text = (postDic["username"] as! String)
                    
                    return cell
                }
            
            }
            
        }else{
            
            let tempDic = self.replyOnPostArray[section - 1]
            
            if tempDic["replyType"] as! String == "audio" {
                
                let tableCell = tableView.dequeueReusableCell(withIdentifier: "threadAudioCommentCell") as! ThreadAudioCommentCell
                tableCell.selectionStyle = .none
                
                
                let date = Date(timeIntervalSince1970: (tempDic["timeCreated"] as! NSString).doubleValue)
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                dateFormatter.timeZone = .current
                let localDate = dateFormatter.string(from: date)
                tableCell.usernameLabel.text = localDate
                
                tableCell.audioTitleLabel.text = (tempDic["audioTitle"] as! String)
                tableCell.audioSlider.value = 0
                tableCell.audioPlayer = nil
                tableCell.sepreatorLabel.isHidden = false
                tableCell.waveformView.isHidden = true
                tableCell.clickableButton.isSelected = false
                tableCell.progressViewConstraint.constant = -(tableCell.waveformView.frame.size.width)
                
                tableCell.clickableButton.tag = section - 1
                tableCell.commentButton.tag = section - 1
                
                tableCell.topThreadLabel.isHidden = true
                let tempArray = self.replyOnPostArray[section - 1]
                let tempSubCommentArray = tempArray["subComment"] as! [Dictionary<String, Any>]
                
                if tempSubCommentArray.isEmpty {
                    tableCell.threadLabel.isHidden = true
                    tableCell.sepreatorLabel.isHidden = false
                }else{
                    tableCell.threadLabel.isHidden = false
                    tableCell.sepreatorLabel.isHidden = true
                }
                
                if self.replyTypeString != "subComment" {
                    if postDic["userID"] as! String == AppDelegate.user._id {
                        tableCell.commentButton.isHidden = false
                    }else{
                        tableCell.commentButton.isHidden = true
                    }
                }else{
                        tableCell.commentButton.isHidden = true
                }
                
                
                tableCell.timer?.invalidate()
                tableCell.url = (tempDic["audioURL"]! as! String)
                
                return tableCell
            }else{
                
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "threadTextCommentCell") as! ThreadTextCommentCell
                
                let date = Date(timeIntervalSince1970: (tempDic["timeCreated"] as! NSString).doubleValue)
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                dateFormatter.timeZone = .current
                let localDate = dateFormatter.string(from: date)
                cell.usernameLabel.text = localDate
                
                cell.topThreadLabel.isHidden = true
                
                
                cell.commentButton.tag = section - 1
                
                let tempArray = self.replyOnPostArray[section - 1]
                let tempSubCommentArray = tempArray["subComment"] as! [Dictionary<String, Any>]
                if tempSubCommentArray.isEmpty {
                    cell.threadLabel.isHidden = true
                    cell.sepreatorLabel.isHidden = false
                    
                }else{
                    cell.threadLabel.isHidden = false
                    cell.sepreatorLabel.isHidden = true
                }
                
                if self.replyTypeString != "subComment" {
                    if postDic["userID"] as! String == AppDelegate.user._id {
                        cell.commentButton.isHidden = false
                    }else{
                        cell.commentButton.isHidden = true
                    }
                }else{
                    cell.commentButton.isHidden = true
                }
                
                cell.messageLabel.text = (tempDic["audioName"] as! String)
                cell.selectionStyle = .none
                
                cell.titleLabel.text = (tempDic["text"] as! String)
                
                return cell
            }
            
            
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section != 0 {
            let tempArray = self.replyOnPostArray[section - 1]
            let tempSubCommentArray = tempArray["subComment"] as! [Dictionary<String, Any>]
            if tempSubCommentArray.isEmpty {return 0}
            return tempSubCommentArray.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tempArray = self.replyOnPostArray[indexPath.section - 1]
        let tempSubCommentArray = tempArray["subComment"] as! [Dictionary<String, Any>]
        
        let tempDic = tempSubCommentArray[0]
        
        if tempDic["replyType"] as! String == "audio" {
            let tableCell = tableView.dequeueReusableCell(withIdentifier: "threadAudioCommentCell", for: indexPath) as! ThreadAudioCommentCell
            tableCell.selectionStyle = .none
            
            
            
            let date = Date(timeIntervalSince1970: (tempDic["timeCreated"] as! NSString).doubleValue)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            tableCell.usernameLabel.text = localDate
            
            
            tableCell.audioTitleLabel.text = (tempDic["audioTitle"] as! String)
            tableCell.audioSlider.value = 0
            tableCell.audioPlayer = nil
            tableCell.sepreatorLabel.isHidden = false
            tableCell.waveformView.isHidden = true
            tableCell.clickableButton.isSelected = false
            tableCell.progressViewConstraint.constant = -(tableCell.waveformView.frame.size.width)
            
            tableCell.commentButton.isHidden = true
            
            tableCell.clickableButton.tag = indexPath.row
            //                tableCell.clickableButton.addTarget(self, action: #selector(clickableTouchUp(sender:)), for: .touchUpInside)
            //
            tableCell.timer?.invalidate()
            tableCell.url = (tempDic["audioURL"]! as! String)
            
            return tableCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "threadTextCommentCell", for: indexPath) as! ThreadTextCommentCell
            
            let date = Date(timeIntervalSince1970: (tempDic["timeCreated"] as! NSString).doubleValue)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            cell.usernameLabel.text = localDate
            
            cell.commentButton.isHidden = true
            
            cell.messageLabel.text = (tempDic["audioName"] as! String)
            cell.selectionStyle = .none
            
            cell.titleLabel.text = (tempDic["text"] as! String)
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        if section == 0{
            
            var tempTypeString = ""
            
            if let postType = postDic["postType"] as? String  {
                tempTypeString = postType
            }
            
            if let replyType = postDic["replyType"] as? String  {
                tempTypeString = replyType
            }
            
            if tempTypeString == "text" {
                return UITableView.automaticDimension
            }
            return 150
        }else{
            let tempDic = self.replyOnPostArray[section - 1]
            
            if tempDic["replyType"] as! String == "text" {
                return UITableView.automaticDimension
            }else{
                return 140
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let tempArray = self.replyOnPostArray[indexPath.section - 1]
        let tempSubCommentArray = tempArray["subComment"] as! [Dictionary<String, Any>]
        let tempDic = tempSubCommentArray[0]
        
        if tempDic["replyType"] as! String == "text" {
            return UITableView.automaticDimension
        }else{
            return 140
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
}

func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
        tempAudioPlayer.stop()
    }
    AppDelegate.currentAudioPlayer.removeAll()
}


extension CommentFeedViewController : GrowingTextViewDelegate{
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0){
            textView.text = nil
            textView.textColor = UIColor.white
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
            textView.text = "Say something..."
            textView.textColor = UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)
            self.sendButton.setBackgroundImage(UIImage(named: "mic"), for: .normal)
        } else{
            self.sendButton.setBackgroundImage(UIImage(named: "sendIcon"), for: .normal)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText.isEmpty {
            self.sendButton.setBackgroundImage(UIImage(named: "mic"), for: .normal)
            self.sendButton.isSelected = false
        }else{
            self.sendButton.setBackgroundImage(UIImage(named: "sendIcon"), for: .normal)
            self.sendButton.isSelected = true
            
        }
        
        return true
    }
}

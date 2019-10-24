//
//  HomeViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 26/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView




class HomeViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate{
   
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
   
    
    let firebaseRefAudioPost = Database.database().reference(withPath: "AudioPosts")
    let dataBaseRefReportPost = Database.database().reference(withPath: "ReportedPosts")
    let dataBaseRefReplyPost = Database.database().reference(withPath: "ReplyOnPost")

    var audioPostArray = [Dictionary<String, Any>]()
    var audioReplyPostArray = [Dictionary<String, Any>]()
    var selectedDic = [String:Any]()
    var lastPlayedIndex = -1
    var selectedIndex = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        indicatorContainerView.isHidden = false
        activityIndicator.startAnimating()

        getAudioPostList()
        
        UIApplication.shared.applicationIconBadgeNumber = 0 
       
        
        Database.database().reference(withPath: "fcmToken").child(Messaging.messaging().fcmToken!)
        
        
    
        DispatchQueue.main.async {
            do {
                let update = try AppDelegate.appDelegate().isUpdateAvailable()
                
                print("update",update)
                DispatchQueue.main.async {
                    if update{
                        
                        if !AppDelegate.isCheckedForUpdate {
                            self.popupUpdateDialogue();

                        }
                        
                    }
                    
                }
            } catch {
                print(error)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.callCommentScreenBy), name: NSNotification.Name(rawValue: "callCommentScreenBy"), object: nil)
     

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
        
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    // MARK:- Private Methode
    // MARK:-
    
    func getAudioPostList(){
        firebaseRefAudioPost.observe(.value) { (snapshot) in
        
            self.getReplyPostList()
            if let tempArray = snapshot.value as? [String:Any] {
                self.audioPostArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
                self.audioPostArray = self.audioPostArray.sorted(by: { (value1, value2) -> Bool in
                    TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
                })
            }
            
            if AppDelegate.isFromPushNotification {
                self.perform(#selector(self.callCommentScreenBy), with: nil, afterDelay: 0.5)
            }
        }
    }
    
    
    func getReplyPostList(){
        dataBaseRefReplyPost.observe(.value) { (snapshot) in
            
            self.indicatorContainerView.isHidden = true
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()

            
            if let tempArray = snapshot.value as? [String:Any] {
                self.audioReplyPostArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
            }
        }
    }
    
    func getReplyCountBy(postId:String) -> Int{
    
        var tempArray = self.audioReplyPostArray.filter { (tempDic) -> Bool in
            tempDic["postId"] as! String == postId
        }
    
        return tempArray.count
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
   @objc func moreButtonClicked(sender:UIButton)
    {
        
        AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
            audioPlayer.stop()
        }
        
        AppDelegate.currentAudioPlayer.removeAll()
        tableView.reloadData()
        
        selectedDic = audioPostArray[sender.tag]
        
        
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReportCommentViewController") as!
        ReportCommentViewController
        controller.selectedDic = selectedDic
        controller.prevController = "home"

        self.present(controller, animated: true, completion: nil)
//        self.commentViewBottomConstraint.constant = 0
//        UIView.animate(withDuration: 0.5) {
//            self.view.layoutIfNeeded()
//        }
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
    
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")

        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
    
    }
    
    func popupUpdateDialogue(){
    
        
        let alertMessage = "A new version of Deep is available, please update for advanced feature";
        let alert = UIAlertController(title: "New Version Available", message: alertMessage, preferredStyle: .alert)
        
        let okBtn = UIAlertAction(title: "Update", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/1451193612"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:"Remind me later" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
            
            AppDelegate.isCheckedForUpdate = true
        })
        alert.addAction(okBtn)
        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK:- Table Delegate and Datasource
    // MARK:-
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if audioPostArray.isEmpty {
//            return 0
//        }
        return audioPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "audioCell") as! AudioTableViewCell
        
            let tempDic = self.audioPostArray[indexPath.row]
            tableCell.labelAudioTitle.text = (tempDic["audioTitle"] as! String)
            tableCell.labelSubHeading.text = (tempDic["username"] as! String)
        tableCell.labelAudioTitle.textColor = UIColor.black
        tableCell.labelSubHeading.textColor = UIColor.black

            tableCell.url = (tempDic["audioURL"]! as! String)
            tableCell.audioLastTimeLabel.text = (tempDic["timeDuration"] as! String)
            
            
            let tempArray = (tempDic["postId"] as! String).components(separatedBy: ".")
            tableCell.commenButton.setTitle("\(getReplyCountBy(postId:tempArray.first!))", for: .normal)

        tableCell.audioPlayer = nil

        tableCell.audioSlider.value = 0
        tableCell.audioCurrentTimeLabel.text = "0:00"
        tableCell.imageWidthConstraint.constant = 0
        tableCell.playButton.isSelected = false
        tableCell.timer?.invalidate()
            
            tableCell.moreButton.addTarget(self, action:#selector(HomeViewController.moreButtonClicked(sender:)) , for: .touchUpInside)
            tableCell.playButton.addTarget(self, action:#selector(HomeViewController.playButtonClicked(sender:)) , for: .touchUpInside)
            tableCell.replyButton.tag = indexPath.row
            tableCell.playButton.tag = indexPath.row
            tableCell.commenButton.tag = indexPath.row
        


        return tableCell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

       if indexPath.row == selectedIndex {
                    AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
                        tempAudioPlayer.stop()
                    }
                    AppDelegate.currentAudioPlayer.removeAll()
        }
    }
  
    
    
    
    @IBAction func replyButtonClicked(_ sender: Any) {
        
        if AppDelegate.isSkipClicked {
           self.setLoginRestriction()
            return
        }
        
        

        AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
            audioPlayer.stop()
        }
        
        AppDelegate.currentAudioPlayer.removeAll()
        tableView.reloadData()
        let button = sender as! UIButton
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplyViewController") as! ReplyViewController
        controller.audioPostDic = self.audioPostArray[button.tag]
        controller.isFromCommentController = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func commentButtonClicked(_ sender: Any) {

        if AppDelegate.isSkipClicked {
            self.setLoginRestriction()
            return 
        }
        
        
        AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
            audioPlayer.stop()
        }
        
        AppDelegate.currentAudioPlayer.removeAll()
        tableView.reloadData()
        
        
        AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
            tempAudioPlayer.stop()
        }
        AppDelegate.currentAudioPlayer.removeAll()
        let button = sender as! UIButton

        selectedDic = audioPostArray[button.tag]
        var tempArray = self.audioReplyPostArray.filter { (tempDic) -> Bool in
              let array = (selectedDic["postId"] as! String).components(separatedBy: ".")
            return tempDic["postId"] as! String == array.first!
        }
        
        tempArray = tempArray.sorted(by: { (value1, value2) -> Bool in
            TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
        })
        
        tempArray.reverse()

        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        controller.commentArray = tempArray
        controller.audioPostDic = selectedDic
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @objc func callCommentScreenBy() {
    
        AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
                  audioPlayer.stop()
              }
              
        AppDelegate.currentAudioPlayer.removeAll()
        tableView.reloadData()
        

        let selectedDicArray = self.audioPostArray.filter { (tempDic) -> Bool in
                  let array = (AppDelegate.userInfo["postId"])!.components(separatedBy: ".")
                        return tempDic["postId"] as! String == array.first!
        }
              
        self.selectedDic = selectedDicArray.first!
//
        var tempArray = self.audioReplyPostArray.filter { (tempDic) -> Bool in
            let array = (AppDelegate.userInfo["postId"])!.components(separatedBy: ".")
                  return tempDic["postId"] as! String == array.first!
            }

        tempArray = tempArray.sorted(by: { (value1, value2) -> Bool in
              TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
          })

        tempArray.reverse()


        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        controller.commentArray = tempArray
        controller.audioPostDic = selectedDic
        self.navigationController?.pushViewController(controller, animated: true)
        

    }

    
    // MARK:- TextView Delegate
    // MARK:-
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment here..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func setLoginToRoot()  {
        
        AppDelegate.appDelegate().window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController:UIViewController
        initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginNav")
        AppDelegate.appDelegate().window?.rootViewController = initialViewController
        AppDelegate.appDelegate().window?.makeKeyAndVisible()
    }
    
    
    func setLoginRestriction(){
        
        
        let alerController = UIAlertController(title: "Alert!", message: "You have to login first in order to access this feature!", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Later", style: .cancel, handler: nil)
        let alertAction2 = UIAlertAction(title: "Login Now", style: .destructive
        ) { (action) in
            DispatchQueue.main.async {
                self.setLoginToRoot()
            }
        }
        
        alerController.addAction(alertAction)
        alerController.addAction(alertAction2)

        self.present(alerController, animated: true, completion: nil)
    }
}


extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}



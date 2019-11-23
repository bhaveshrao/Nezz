//
//  ReplyViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 27/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView
import Firebase

class ReplyViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var viewTrack: UIView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var replyStatusLabel: UILabel!
    
    @IBOutlet weak var replyStatusLabel2: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postButton2: UIButton!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sliderCurrentTimeLabel: UILabel!
    @IBOutlet weak var sliderLastTimeLabel: UILabel!
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicatorLoader: NVActivityIndicatorView!
    
    @IBOutlet weak var audioReplyView: UIView!
    @IBOutlet weak var textReplyView: UIView!
    
    @IBOutlet weak var textReply: UIButton!
    @IBOutlet weak var textReplyLabel: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var storageRef = Storage.storage().reference()
    let firebaseRefReplyAudioPost = Database.database().reference(withPath: "ReplyOnPost")
    
    var session = AVAudioSession.sharedInstance()

   

    var audioPostDic = Dictionary<String, Any>()
    var isFromCommentController = false
    var timer: Timer?
    var timerFor2Minutes: Timer?
    var timerForRecorder: Timer?
    var userIdSet = Set<String>()

    var randomeInt:Int?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicatorContainerView.isHidden = true
        textReplyView.isHidden = true
        
        textView.delegate = self
        
        textView.text = "Type Your Reply Here..."
        textView.textColor = UIColor.lightGray

        audioSlider.setThumbImage(UIImage(named: "toggle"), for: .normal)
        audioSlider.setThumbImage(UIImage(named: "toggle"), for: .highlighted)


        self.viewTrack.layer.borderColor = UIColor(displayP3Red: 11.0/255.0, green: 208.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor
        self.viewTrack.layer.borderWidth = 1.0
        self.viewTrack.layer.cornerRadius = 7
        self.viewTrack.clipsToBounds = true


        // Do any additional setup after loading the view.

        self.recordLabel.text = "0:00"
        self.replyStatusLabel.text = "Reply to " + (audioPostDic["username"] as! String)
        
        self.replyStatusLabel2.text = "Reply to " + (audioPostDic["username"] as! String)
        
        self.sliderLastTimeLabel.text = "0:00"
        self.sliderCurrentTimeLabel.text = "0:00"
        self.playerControlIntraction(isEnable: false)
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)

            recordingSession.requestRecordPermission { (isAllowed) in
                DispatchQueue.main.async {
                    if isAllowed {

                    } else {
                        let alerController = UIAlertController(title: "Permission not granted!", message: "Go to Setting>> Nezz >> Microphone.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alerController.addAction(alertAction)
                        self.present(alerController, animated: true, completion: nil)                    }
                }
            }
        } catch {
            // failed to record!
        }

        Messaging.messaging().sendMessage(["message":"hii"], to: "e4OBBRVJURI:APA91bGwlNtMTZPAoXM9MNTebog7vpt7McrgldFkrdq6arHJ_1LaWAyKQ3ILhX_RjJaqzmD3mjeotNRDCRYN05aFJ8BDi9KPn2x-mM_WLExOp0oWbi9JpIeUr6qA6OpBwJxNmMoZ4Kx-@gcm.googleapis.com", withMessageID: "001", timeToLive: 100)
        
        
        print(self.audioPostDic["postId"] as! String)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReplyViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReplyViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        postButton2.isEnabled = false
        postButton2.alpha  = 0.5
        
        if let nav = self.navigationController {
            print(nav)
            textReply.isHidden = false
            textReplyLabel.isHidden = false
        }else{
            textReply.isHidden = true
            textReplyLabel.isHidden = true

        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if audioPlayer != nil {
            if audioPlayer.isPlaying{
                audioPlayer.pause()
                audioPlayer = nil
            }
        }
        
        
        AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
            tempAudioPlayer.stop()
        }
        AppDelegate.currentAudioPlayer.removeAll()
        
        timer?.invalidate()
        timerFor2Minutes?.invalidate()
        
    }
    
    // MARK:- Private Number
    // MARK:-
    
    
    func callForPushNotification(userId:String) {
        let session = URLSession.shared
        let url = URL(string: "http://104.248.118.154:3000/api/sendnotificationbyid")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let tempArray = (self.audioPostDic["postId"] as! String).components(separatedBy: ".")
        
        let json = [
            "title": "TooDeep",
            "message": AppDelegate.user.username + " has commented on your post",
            "userkey" :userId,
            "commentedBy" : AppDelegate.user.uid,
            "notificationType" : "comment",
            "postId" : (tempArray.first)!
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
        }
        task.resume()
    }
    
    
    func callForPushNotification(userId: [String]) {
        let session = URLSession.shared
        let url = URL(string: "http://104.248.118.154:3000/api/sendnotificationbyid")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let tempArray = (self.audioPostDic["postId"] as! String).components(separatedBy: ".")

        
        let json = [
            "title": "TooDeep",
            "message": AppDelegate.user.username + " has commented on your post",
            "userkeyArr" :userId,
            "commentedBy" : AppDelegate.user.uid,
            "notificationType" : "comment",
            "postId" : (tempArray.first)!

            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
        }
        task.resume()
    }

    
    
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("Recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            
            
            do {
                try session.setCategory(.record , mode: .default , options: .defaultToSpeaker)
            }catch{
                print(error)
            }
            
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            timerFor2Minutes = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false, block: { (timer) in
                self.finishRecording(success: true)
            })
            
            
            timerForRecorder = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateRecordingTime), userInfo: nil, repeats: true)
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getAudiFileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("Recording.m4a")
    }
    
    @objc func finishRecording(success: Bool) {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
            timerForRecorder?.invalidate()

        }
    }
    
    @objc func updateRecordingTime(){
        
        DispatchQueue.main.async {
            if self.audioRecorder != nil {
                self.recordLabel.text = self.audioRecorder.currentTime.toMM_SS()
                
            }
        }
    
    }
    
    @objc func updateSlider(){
        
        if audioPlayer != nil {
            audioSlider.value = Float(audioPlayer.currentTime)
            
            self.sliderCurrentTimeLabel.text = audioPlayer.currentTime.toMM_SS()
            
            let updatedValueForTrack = Float(audioPlayer.currentTime) / Float(audioPlayer.duration)
            //        print("Duration \(audioPlayer.duration)")
            //        print("Changing works \(audioSlider.value)")
            
            print(" \(updatedValueForTrack)")
            
            
            let widthView = self.viewTrack.frame.width
            
            let value = CGFloat(CGFloat(updatedValueForTrack) * CGFloat(widthView))
            self.imageWidthConstraint.constant = value
        }
    }
    
    func playerControlIntraction(isEnable:Bool){
        
        audioPlayer = nil
        if isEnable {
            playButton.alpha = 1
            retakeButton.alpha = 1
            postButton.alpha = 1
            
        }else{
            playButton.alpha = 0.5
            retakeButton.alpha = 0.5
            postButton.alpha = 0.5
        }
        
        self.sliderCurrentTimeLabel.text = "0:00"
        
        activityIndicator.stopAnimating()
        recordButton.isSelected = false
        recordButton.setImage(UIImage(named: "play_big"), for: .normal)
        
        playButton.isUserInteractionEnabled = isEnable
        retakeButton.isUserInteractionEnabled = isEnable
        audioSlider.isUserInteractionEnabled = isEnable
        imageWidthConstraint.constant = 0
        audioSlider.value = 0
    }
    
    func handleAudioSendWith(url: String) {
        guard let fileUrl = URL(string: url) else {
            return
        }
        
        randomeInt = Int.random(in: 500...50000)
        
        let fileName = AppDelegate.user.uid + String(format: "%d", randomeInt!) + ".m4a"
        
        
        self.indicatorContainerView.isHidden = false
        self.activityIndicatorLoader.startAnimating()
        
        storageRef.child(fileName).putFile(from: fileUrl, metadata: nil) { (storageData, error) in
            if error == nil {
                
                
                
                self.storageRef.child(fileName).downloadURL(completion: { (url, error) in
                    print(url!)
                    
                    self.indicatorContainerView.isHidden = true
                    self.activityIndicatorLoader.stopAnimating()
                    
                    var tempArray = [String]()
                    if !(self.isFromCommentController) {
                       tempArray = (self.audioPostDic["postId"] as! String).components(separatedBy: ".")
                    }else{
                       tempArray =  (self.audioPostDic["audioName"] as! String).components(separatedBy: ".")
                    }
                    
                    var notificationType = ""
                    
                    if self.isFromCommentController {
                        notificationType = "userComment"
                    }else{
                        notificationType = "comment"
                    }

                    
                    let audioReplyPost = ReplyOnPost(replyTo: self.audioPostDic["userID"] as! String, replyBy: AppDelegate.user.uid, audioTitle: self.audioPostDic["audioTitle"] as! String, audioName:(storageData?.name)! , audioURL: (url?.absoluteString)!, timeCreated: Date().timeIntervalSince1970, timeDuration: (self.sliderLastTimeLabel.text)!, postId: tempArray[0],  username: AppDelegate.user.username, replyType:"audio",text: "",notificationType: notificationType)
                    
                    
                    let tempArray2 = fileName.components(separatedBy: ".")

                    self.firebaseRefReplyAudioPost.child(tempArray2[0]).setValue(audioReplyPost.toAnyObject())
                    
                    if self.isFromCommentController {
                        var arrayUserId =  [String](self.userIdSet)
                        if !(arrayUserId.contains(self.audioPostDic["replyBy"] as! String) ){
                            arrayUserId.append(self.audioPostDic["replyBy"] as! String)
                        }
                        self.callForPushNotification(userId: arrayUserId)
                    }else{
                        self.callForPushNotification(userId: self.audioPostDic["userID"] as! String)
                    }

                    
                    let alerController = UIAlertController(title: "Congratulations!!", message: "Your audio has been posted successfully!!", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { (alert) in
                        
                        DispatchQueue.main.async {
                            
                            
                            if let nav = self.navigationController {
                                nav.popViewController(animated: true)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callHome"), object: nil)
                            }else{
                                self.dismiss(animated: true, completion: nil)
                                
                            }
                        }
                        
                    })
                    
                    alerController.addAction(alertAction)
                    self.present(alerController, animated: true, completion: nil)
                    
                    self.sliderLastTimeLabel.text = "0:00"
                    self.sliderCurrentTimeLabel.text = "0:00"
                    self.recordLabel.text = "0:00"

                    self.playerControlIntraction(isEnable: false)
                    
                })
            }
        }
    }
    
    func handleTextReplySendWith(message: String) {
        
        randomeInt = Int.random(in: 500...50000)
        
        let fileName = AppDelegate.user.uid + String(format: "%d", randomeInt!)
        
        
        self.indicatorContainerView.isHidden = false
        self.activityIndicatorLoader.startAnimating()
        
        var tempArray = [String]()
        if !(self.isFromCommentController) {
            tempArray = (self.audioPostDic["postId"] as! String).components(separatedBy: ".")
        }else{
            tempArray =  (self.audioPostDic["audioName"] as! String).components(separatedBy: ".")
        }

        var notificationType = ""
                           
                           if self.isFromCommentController {
                               notificationType = "userComment"
                           }else{
                               notificationType = "comment"
                           }
        
        let audioReplyPost = ReplyOnPost(replyTo: self.audioPostDic["userID"] as! String, replyBy: AppDelegate.user.uid, audioTitle: self.audioPostDic["audioTitle"] as! String, audioName: fileName , audioURL: "", timeCreated: Date().timeIntervalSince1970, timeDuration: "", postId: tempArray[0],  username: AppDelegate.user.username, replyType: "text", text: message,notificationType: notificationType)
        
        
        
        self.firebaseRefReplyAudioPost.child(fileName).setValue(audioReplyPost.toAnyObject())
        
        if self.isFromCommentController {
            var arrayUserId =  [String](self.userIdSet)
            if !(arrayUserId.contains(self.audioPostDic["replyBy"] as! String) ){
                arrayUserId.append(self.audioPostDic["replyBy"] as! String)
            }
            self.callForPushNotification(userId: arrayUserId)
        }else{
            self.callForPushNotification(userId: self.audioPostDic["userID"] as! String)
        }
        
        let alerController = UIAlertController(title: "Congratulations!!", message: "Your reply has been posted successfully!!", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { (alert) in
            
            DispatchQueue.main.async {
        
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callHome"), object: nil)
            }
            
        })
        
        alerController.addAction(alertAction)
        self.present(alerController, animated: true, completion: nil)
        
        
//        storageRef.child(fileName).
    }
    
    
    
    func prepareAudioPlayer(){
        if audioPlayer == nil {
            
            let url = self.getDocumentsDirectory()
            let pathComponent = url.appendingPathComponent("Recording.m4a")
            let filePath = pathComponent.path
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                do{
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                    audioSlider.value = 0.0
                    audioPlayer.delegate = self
                    audioSlider.maximumValue =  Float(audioPlayer.duration)
                    self.sliderLastTimeLabel.text = audioPlayer.duration.toMM_SS()
                    
                    do {
                        try session.setCategory(.playback , mode: .default , options: .defaultToSpeaker)
                    }catch{
                        print(error)
                    }
                    
                    AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
                        audioPlayer.stop()
                    }
                    
                    AppDelegate.currentAudioPlayer.removeAll()
                    
                    AppDelegate.currentAudioPlayer.append(audioPlayer)
                    audioPlayer.prepareToPlay()
                }catch{
                    print(error)
                }
            } else {
                let alerController = UIAlertController(title: "Error!", message: "There is no recoding to play!!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alerController.addAction(alertAction)
                self.present(alerController, animated: true, completion: nil)
            }
        }
    }

    
    
    // MARK:- Tableview Delegate And DataSource
    // MARK:-
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let audioTableCell = tableView.dequeueReusableCell(withIdentifier: "audioReplyCell", for: indexPath) as! AudioReplyTableViewCell
        let textTableCell = tableView.dequeueReusableCell(withIdentifier: "textReplyCell") as! TextReplyTableViewCell
        
        
        if let reply = audioPostDic["replyType"]  {
            
            if reply as! String == "text" {
                textTableCell.labelAudioTitle.text = "Reply by " + (audioPostDic["username"] as! String)
                textTableCell.labelTextReply.text = (audioPostDic["text"] as! String)
                textTableCell.labelSubHeading.text = (audioPostDic["username"] as! String)

                return textTableCell
            }

        }

        audioTableCell.labelAudioTitle.text = (audioPostDic["audioTitle"] as! String)
        audioTableCell.labelSubHeading.text = (audioPostDic["username"] as! String)
        audioTableCell.url = (audioPostDic["audioURL"]! as! String)
        audioTableCell.audioLastTimeLabel.text = (audioPostDic["timeDuration"] as! String)
        audioPlayer = audioTableCell.audioPlayer
        audioTableCell.audioPlayer = nil
        audioTableCell.audioSlider.value = 0
        audioTableCell.audioCurrentTimeLabel.text = "0:00"
        audioTableCell.imageWidthConstraint.constant = 0
        audioTableCell.playButton.isSelected = false
        audioTableCell.timer?.invalidate()
        
        
        audioTableCell.replyButton.isHidden = true
        audioTableCell.commenButton.isHidden = true
        audioTableCell.moreButton.isHidden = true
        
        audioTableCell.playButton.tag = indexPath.row
        
        return audioTableCell

      
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let reply = audioPostDic["replyType"] {
            if reply as! String == "text"{
                return 115
            }
        }
        return 160

    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        
       if let reply = audioPostDic["replyType"] {
       
        if reply as! String == "text"{
            self.tableViewHeightConstraint.constant = 115
            return UITableView.automaticDimension
        }
        
        }
        
//        self.tableViewHeightConstraint.constant = 160

        return 160
    }
    
    
    // MARK:- Delegates
    // MARK:-
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.playerControlIntraction(isEnable: true)
        prepareAudioPlayer()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if audioPlayer != nil {
            print("called.. finish Playing")
            audioPlayer = nil
            timer?.invalidate()
            playButton.isSelected = false
            audioSlider.value = 0
            self.sliderCurrentTimeLabel.text = "0:00"
            imageWidthConstraint.constant = 0
        }
        
    }

    

    
    // MARK:- User Action
    // MARK:-
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        if audioPlayer != nil {
            if audioPlayer.isPlaying{
                audioPlayer.pause()
                audioPlayer = nil
            }
        }
        
        AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
            tempAudioPlayer.stop()
        }
        AppDelegate.currentAudioPlayer.removeAll()
        
        timer?.invalidate()
        timerFor2Minutes?.invalidate()
        
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func playButtonClicked(_ sender: Any) {
        let button = sender as! UIButton
        
        prepareAudioPlayer()
        
        if button.isSelected {
            button.isSelected = false
            audioPlayer.pause()
            
        }else {
            button.isSelected = true
            audioPlayer.play()
            timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        }
    }
    
    
    @IBAction func postButtonClicked(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if button == self.postButton2 {
            self.handleTextReplySendWith(message: textView.text)
        }else{
            if audioPlayer != nil {
                if audioPlayer.isPlaying {
                    playButton.isSelected = false
                    audioPlayer.pause()
                    
                }
            }
            self.handleAudioSendWith(url: getAudiFileURL().absoluteString)
        }
    
    }
    
    
    @IBAction func retakeButtonClicked(_ sender: Any) {
        
    
        AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
            tempAudioPlayer.stop()
        }
        AppDelegate.currentAudioPlayer.removeAll()
        
        
        self.sliderLastTimeLabel.text = "0:00"
        self.recordLabel.text = "0:00"
        playButton.isSelected = false
        
        playerControlIntraction(isEnable: false)
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        
        if audioPlayer != nil {
            audioPlayer.currentTime = TimeInterval(audioSlider.value)
            
            let widthView = self.viewTrack.frame.width
            let updatedValueForTrack = Float(audioPlayer.currentTime) / Float(audioPlayer.duration)
            
            let value = CGFloat(CGFloat(updatedValueForTrack) * CGFloat(widthView))
            print(value)
            print(audioSlider.value)
            self.imageWidthConstraint.constant = value
        }
    }
    
    
    
    @IBAction func startRecordingCicked(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if button.isSelected {
            
            DispatchQueue.main.async {
                button.isSelected = false
                self.activityIndicator.stopAnimating()
                self.timerFor2Minutes?.invalidate()
                button.setImage(UIImage(named: "play_big"), for: .normal)
                self.finishRecording(success: true)
            }
          
        }else{
            
            DispatchQueue.main.async {
                
                button.isSelected = true
                self.activityIndicator.startAnimating()
                button.setImage(nil, for: .normal)
                
                self.playButton.alpha = 0.5
                self.retakeButton.alpha = 0.5
                self.postButton.alpha = 0.5
                self.sliderLastTimeLabel.text = "0:00"
                self.playButton.isUserInteractionEnabled = false
                self.retakeButton.isUserInteractionEnabled = false
                self.audioSlider.isUserInteractionEnabled = false
                
                self.startRecording()
            }
            
            
        }
        
        
    }
    
    @IBAction func ToogleButtonClicked(_ sender: Any) {
        let button = sender as! UIButton
        
        if button.tag == 100{
            textReplyView.isHidden = false
            audioReplyView.isHidden = true

        }else {
            textReplyView.isHidden = true
            audioReplyView.isHidden = false
        }
        
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.5) {
                self.view.frame = CGRect(x:self.view.frame.origin.x , y: -(keyboardSize.size.height/2), width: self.view.frame.size.width, height: self.view.frame.size.height)
                }
            }

        }
    }
@objc func keyboardWillHide(notification: Notification) {
//        self.bottomScrollConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(x:self.view.frame.origin.x , y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
}
    
extension ReplyViewController : UITextViewDelegate {
    
    // MARK:- Delegate Methode
    // MARK:-
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.resignFirstResponder()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type Your Reply Here..."
            textView.textColor = UIColor.lightGray
            postButton2.isEnabled = false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.postButton2.isEnabled = false
            postButton2.alpha  = 0.5

        }else{
            self.postButton2.isEnabled = true
            postButton2.alpha  = 1

        }
    }
}

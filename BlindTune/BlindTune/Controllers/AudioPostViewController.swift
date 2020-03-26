//
//  AudioPostViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 12/03/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AVFoundation
import Firebase

class AudioPostViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicatorMain: NVActivityIndicatorView!
    
    @IBOutlet weak var waveformView: SCSiriWaveformView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var redoView: UIView!
    
    var timer: Timer?
    var timerForRecorder: Timer?
    
    var timeRecordingDuration = ""
    var session = AVAudioSession.sharedInstance()
    
    var timerFor2Minutes: Timer?
    var randomeInt:Int?
    @IBOutlet weak var sliderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sliderView: UIView!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var isControllerType = ""
    var postDic: Dictionary<String, Any> = [:]
    
    
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var progressViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldContainerView: UIView!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    
    
    @IBOutlet weak var audioSlider: UISlider!
    var storageRef = Storage.storage().reference()
    
    
    @IBOutlet weak var buttonBackground: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.waveformView.primaryWaveLineWidth = 1.0
        self.waveformView.secondaryWaveLineWidth = 1.0
        
        self.progressView.isHidden = true
        self.sliderView.isHidden = true
        
        activityIndicatorMain.isHidden = true
        indicatorContainerView.isHidden = true
        
        audioSlider.transform = CGAffineTransform(scaleX: 1, y: 6)
        
        self.sliderHeightConstraint.constant = 0.01
        //        self.waveformView.isHidden = true
        
        audioSlider.setThumbImage(UIImage(named: "thumbLine"), for: .normal)
        self.audioSlider.maximumValue = 0
        self.progressView.isHidden = false
        //        self.progressLabel.isHidden = true
        
        self.progressViewConstraint.constant = -(self.waveformView.frame.size.width)
        self.progressLabel.center = self.audioSlider.thumbCenterX
        
        self.redoView.isHidden = true
        
        self.textFieldContainerView.isHidden = true
        
        self.timeLabel.text = "0:00"
        
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
        
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if audioPlayer != nil {
            if audioPlayer.isPlaying{
                audioPlayer.pause()
                audioPlayer = nil
            }
        }
        
        timer?.invalidate()
        timerFor2Minutes?.invalidate()
        
    }
    
    // MARK:- User Action
    // MARK:-
    
    @IBAction func audioButtonAction(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if button.isSelected {
            button.isSelected = false
            activityIndicator.stopAnimating()
            timerFor2Minutes?.invalidate()
            self.timeRecordingDuration = self.timeLabel.text!
            self.finishRecording(success: true)
        }else{
            button.isSelected = true
            activityIndicator.startAnimating()
            button.setImage(nil, for: .normal)
            self.timeLabel.text = "0:00"
            audioSlider.isUserInteractionEnabled = false
            self.startRecording()
        }
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func redoAction(_ sender: Any) {
        
        self.redoView.isHidden = true
        self.audioView.isHidden = false
        self.progressView.isHidden = true
        self.sliderView.isHidden = true
        self.timeLabel.text = "00:00"
    }
    
    @IBAction func nextAction(_ sender: Any) {
        //        self.textFieldContainerView.isHidden = false
        
        if self.isControllerType == "replyOnPost" {
            
            self.handleAudioSendWith(url: getAudiFileURL().absoluteString, title: "")
            
        }else{
            
            let child = self.storyboard?.instantiateViewController(withIdentifier: "TitleChildViewController") as! TitleChildViewController
            self.addChild(child)
            self.buttonBackground.isUserInteractionEnabled = false
            child.view.frame = self.textFieldContainerView.frame
            self.view.addSubview(child.view)
            child.didMove(toParent: self)
        }
        
    }
    
    
    
    
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        
        let button = sender as! UIButton
        if button.isSelected {
            button.isSelected = false
            audioPlayer.pause()
            
        }else{
            button.isSelected = true
            if audioPlayer == nil{
                self.prepareAudioPlayer()
            }else{
                
                audioPlayer.play()
            }
        }
        
        //        self.downloadFileFromURL(url: self.url!)
        
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        
        if audioPlayer != nil {
            
            self.audioSlider.isUserInteractionEnabled = true
            
            audioPlayer.currentTime = TimeInterval(audioSlider.value)
            
            let widthView = self.view.frame.width
            let updatedValueForTrack = Float(audioPlayer.currentTime) / Float(audioPlayer.duration)
            
            let value = CGFloat(CGFloat(updatedValueForTrack) * CGFloat(widthView))
            print(value)
            print(audioSlider.value)
            self.progressViewConstraint.constant = value
        }
    }
    
    
    
    // MARK:- Private Method
    // MARK:-
    
    
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
                    audioPlayer.isMeteringEnabled = true
                    
                    audioSlider.maximumValue =  Float(audioPlayer.duration)
                    self.timeLabel.text = audioPlayer.duration.toMM_SS()
                    
                    do {
                        try session.setCategory(.playback , mode: .default , options: .defaultToSpeaker)
                    }catch{
                        print(error)
                    }
                    
                    
                    self.timer = Timer.scheduledTimer(timeInterval:0.01, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.timer!, forMode: .common)
                    
                    
                    AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
                        audioPlayer.stop()
                    }
                    
                    AppDelegate.currentAudioPlayer.removeAll()
                    
                    AppDelegate.currentAudioPlayer.append(audioPlayer)
                    
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
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
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            
            timerFor2Minutes = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false, block: { (timer) in
                self.finishRecording(success: true)
            })
            
            timerForRecorder = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateRecordingTime), userInfo: nil, repeats: true)
            
            
            
            //            recordStatusLabel.text = "Tap to Stop"
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
            activityIndicator.stopAnimating()
            self.redoView.isHidden = false
            self.view.bringSubviewToFront(self.redoView)
            self.audioView.isHidden = true
            self.progressView.isHidden = false
            self.sliderView.isHidden = false
            audioRecorder = nil
            timerForRecorder?.invalidate()
            //            recordStatusLabel.text = "Tap to Record..."
        }
    }
    
    @objc func updateRecordingTime(){
        
        DispatchQueue.main.async {
            if self.audioRecorder != nil {
                self.audioRecorder.updateMeters()
                let normalizedValue = self.normalizedPowerLevel(fromDecibels: CGFloat(self.audioRecorder.averagePower(forChannel: 0)))
                self.waveformView.update(withLevel: normalizedValue)
                self.timeLabel.text = self.audioRecorder.currentTime.toMM_SS()
            }
        }
    }
    
    
    @objc func updateSlider(){
        
        DispatchQueue.main.async {
            
            if self.audioPlayer != nil {
                let widthView = self.waveformView.frame.width
                let updatedValueForTrack = Float(self.audioPlayer.currentTime) / Float(self.audioPlayer.duration)
                let value = CGFloat(CGFloat(updatedValueForTrack) * CGFloat(widthView))
                self.audioSlider.value = Float(self.audioPlayer.currentTime)
                self.timeLabel.text = self.audioPlayer.currentTime.toMM_SS()
                self.progressLabel.center = self.audioSlider.thumbCenterX
                self.audioPlayer.updateMeters()
                let normalizedValue = self.normalizedPowerLevel(fromDecibels: CGFloat(self.audioPlayer.averagePower(forChannel: 0)))
                self.progressViewConstraint.constant =  -(widthView) + value
                print(value)
                print(self.progressViewConstraint.constant)
                self.waveformView.update(withLevel: normalizedValue)
            }
        }
        
    }
    
    func normalizedPowerLevel(fromDecibels decibels: CGFloat) -> CGFloat {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        return CGFloat(powf((powf(10.0, Float(0.05 * decibels)) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0))
    }
    
    
    func handleAudioSendWithTitle(title:String){
        handleAudioSendWith(url: getAudiFileURL().absoluteString, title: title)
    }
    
    func handleAudioSendWith(url: String , title:String) {
        guard let fileUrl = URL(string: url) else {
            return
        }
        
        randomeInt = Int.random(in: 1...100000)
        
        let fileName = AppDelegate.user.username + String(format: "%d", randomeInt!) + ".m4a"
        
        self.indicatorContainerView.isHidden = false
        self.activityIndicatorMain.startAnimating()
        
        
        storageRef.child(fileName).putFile(from: fileUrl, metadata: nil) { (storageData, error) in
            if error == nil {
                
                
                self.storageRef.child(fileName).downloadURL(completion: { (url, error) in
                    print(url!)
                    
                    self.indicatorContainerView.isHidden = true
                    self.activityIndicatorMain.stopAnimating()
                    
                    let tempArray = (storageData?.name)!.components(separatedBy: ".")
                    
                    
                    if self.isControllerType == "createPost" {
                        
                        let audioPost = AudioPost(userID: AppDelegate.user._id, audioTitle: title,
                                                  audioName: (storageData?.name)!, audioURL: (url?.absoluteString)!,
                                                  username: AppDelegate.user.username,
                                                  timeCreated:(storageData?.timeCreated?.timeIntervalSinceReferenceDate)! ,
                                                  timeDuration: self.timeRecordingDuration, postId :tempArray[0] ,
                                                  commentCount : 0, postType: "audio",text: "")
                        
                        
                        self.sendAudioDataToServer(parameters: audioPost.toAnyObject() as! [String : Any])
                        
                    }else if self.isControllerType == "subComment"{
                        
                        let parameters = [
                          "subComment": [[
                            "audioName": (storageData?.name)!,
                            "audioTitle": "",
                            "audioURL": (url?.absoluteString)!,
                            "postId": self.postDic["_id"] as! String,
                            "replyBy": AppDelegate.user._id,
                            "replyTo": self.postDic["replyBy"] as! String,
                            "replyType": "audio",
                            "text": "",
                            "timeCreated": "\(Date().timeIntervalSince1970)",
                            "timeDuration": self.timeRecordingDuration,
                            "username": AppDelegate.user.username,
                            "subComment": []
                            ]], ]
                         as [String : Any]
                        
                        
                        self.submitAudioSubComment(byID: self.postDic["_id"] as! String, parameters: parameters)
                        
                        
                    }else{
                    
                        
                        let parameters = [
                            "audioName": (storageData?.name)!,
                            "audioTitle": title,
                            "audioURL": (url?.absoluteString)!,
                            "postId": self.postDic["_id"] as! String,
                            "replyBy": AppDelegate.user._id,
                            "replyTo": self.postDic["userID"] as! String,
                            "replyType": "audio",
                            "text": "",
                            "timeCreated": "\(Date().timeIntervalSince1970)",
                            "timeDuration": self.timeRecordingDuration,
                            "username": AppDelegate.user.username,
                            "subComment": []
                            ] as [String : Any]
                        
                        self.submitAudioCommentOnServer(parameters: parameters)
                    }
                })
            }
        }
    }
    
    
    func submitAudioSubComment(byID:String, parameters: [String:Any]){
        
        let headers = [
          "content-type": "application/json",
          "cache-control": "no-cache",
          "postman-token": "9078ecf6-2d0c-54da-21d1-bd84ead7a7e2"
        ]
        

        
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

    
func submitAudioCommentOnServer(parameters: [String:Any]){
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "1c9bf83e-6ab0-01e9-717d-2c7ade2ac21e"
        ]
        
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
    
    
    func sendAudioDataToServer(parameters:[String:Any]){
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "53a05c1c-f6a1-5b07-50c6-1f247c36c78f"
        ]
        
        var postData = Data()
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }catch {
            print(error)
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://104.248.118.154:6004/audioPost/create/")! as URL,
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
                let httpResponse = response as? HTTPURLResponse
                
                DispatchQueue.main.async {
                    let alerController = UIAlertController(title: "Congratulations!!", message: "Your audio has been posted successfully!!", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                        DispatchQueue.main.async {
                            self.navigationController?.viewControllers.forEach({ (ctrl) in
                                if ctrl.isKind(of: HomeFeedViewController.classForCoder()) {
                                    self.navigationController?.popToViewController(ctrl, animated: true)
                                }
                            })
                        }
                    })
                    alerController.addAction(alertAction)
                    self.present(alerController, animated: true, completion: nil)
                    
                    self.timeLabel.text = "0:00"
                }
                
            }
        })
        dataTask.resume()
    }
    
    
    // MARK:- Delegates
    // MARK:-
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //        self.playerControlIntraction(isEnable: true)
        //        prepareAudioPlayer()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if audioPlayer != nil {
            print("called.. finish Playing")
            progressViewConstraint.constant = -(self.view.frame.size.width)
            audioSlider.value = 0
            self.audioPlayer = nil
            self.timer?.invalidate()
            self.progressLabel.text = "0:00"
            self.buttonBackground.isSelected = false
        }
    }
}

extension TimeInterval {
    func toMM_SS() -> String {
        let interval = self
        let componentFormatter = DateComponentsFormatter()
        
        componentFormatter.unitsStyle = .positional
        componentFormatter.zeroFormattingBehavior = .pad
        componentFormatter.allowedUnits = [.minute, .second]
        return componentFormatter.string(from: interval) ?? ""
    }
}

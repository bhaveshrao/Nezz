//
//  AddPostViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 26/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AVFoundation
import Firebase
class AddPostViewController: UIViewController, UITextFieldDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var viewTrack: UIView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var recordStatusLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postButton2: UIButton!

    @IBOutlet weak var postTitleTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!

    @IBOutlet weak var sliderCurrentTimeLabel: UILabel!
    @IBOutlet weak var sliderLastTimeLabel: UILabel!
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicatorLoader: NVActivityIndicatorView!
    var session = AVAudioSession.sharedInstance()

    var storageRef = Storage.storage().reference()
    let firebaseRefAudioPost = Database.database().reference(withPath: "AudioPosts")

    var timer: Timer?
    var timerForRecorder: Timer?

    var timerFor2Minutes: Timer?
    var randomeInt:Int?

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioSlider.setThumbImage(UIImage(named: "toggle"), for: .normal)
        audioSlider.setThumbImage(UIImage(named: "toggle"), for: .highlighted)

        self.imageWidthConstraint.constant = 0
        indicatorContainerView.isHidden = true

        self.viewTrack.layer.borderColor = UIColor(displayP3Red: 11.0/255.0, green: 208.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor
        self.viewTrack.layer.borderWidth = 1.0
        self.viewTrack.layer.cornerRadius = 7
        self.viewTrack.clipsToBounds = true
        // Do any additional setup after loading the view.
        
        self.recordLabel.text = "0:00"
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        postTitleTextField.resignFirstResponder()
    }
    
    // MARK:- Private Method
    // MARK:-
    
    
    
    
    
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

        
            
            recordStatusLabel.text = "Tap to Stop"
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
            recordStatusLabel.text = "Tap to Record..."
        }
    }
    
    @objc func updateRecordingTime(){
        if audioRecorder != nil {
            self.recordLabel.text = audioRecorder.currentTime.toMM_SS()

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
        
        randomeInt = Int.random(in: 1...500)

        let fileName = AppDelegate.user.uid + String(format: "%d", randomeInt!) + ".m4a"
        
       
        self.indicatorContainerView.isHidden = false
        self.activityIndicatorLoader.startAnimating()
        
        storageRef.child(fileName).putFile(from: fileUrl, metadata: nil) { (storageData, error) in
            if error == nil {
              
            
                
                self.storageRef.child(fileName).downloadURL(completion: { (url, error) in
                    print(url!)
                    
                    self.indicatorContainerView.isHidden = true
                    self.activityIndicatorLoader.stopAnimating()
                    
                    let tempArray = (storageData?.name)!.components(separatedBy: ".")

                    
                    let audioPost = AudioPost(userID: AppDelegate.user.uid, audioTitle: self.postTitleTextField.text!, audioName: (storageData?.name)!, audioURL: (url?.absoluteString)!, username: AppDelegate.user.username, timeCreated:(storageData?.timeCreated?.timeIntervalSinceReferenceDate)! , timeDuration: (self.sliderLastTimeLabel.text)!, postId :tempArray[0] , commentCount : 0)
                    self.firebaseRefAudioPost.child(tempArray[0]).setValue(audioPost.toAnyObject())
                    
                    self.callForPushNotification(postId: tempArray[0])
                    
                    
                    let alerController = UIAlertController(title: "Congratulations!!", message: "Your audio has been posted successfully!!", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callHome"), object: nil)
                        }
                    })
                    alerController.addAction(alertAction)
                    self.present(alerController, animated: true, completion: nil)
                    
                    self.postTitleTextField.text = ""
                    self.sliderLastTimeLabel.text = "0:00"
                    self.sliderCurrentTimeLabel.text = "0:00"
                    self.recordLabel.text = "0:00"
                    self.playerControlIntraction(isEnable: false)

                })
        }
    }
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
    
    
    func callForPushNotification(postId: String) {
        let session = URLSession.shared
        let url = URL(string: "http://104.248.118.154:3000/api/sendnotificationall")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
     
        let json = [
            "title": "TooDeep",
            "message": AppDelegate.user.username + " has added a new post",
            "userkey" : AppDelegate.user.uid,
            "commentedBy" : AppDelegate.user.uid,
            "notificationType" : "addPost",
            "postId" : postId
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
        }
         task.resume()
    }

    // MARK:- Delegates
    // MARK:-
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        postTitleTextField.resignFirstResponder()
        return true
    }
    
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
        
        if (postTitleTextField.text?.isEmpty)! {
            postTitleTextField.shake()
            return
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
            postTitleTextField.resignFirstResponder()
        
            if button.isSelected {
                button.isSelected = false
                activityIndicator.stopAnimating()
                timerFor2Minutes?.invalidate()
                button.setImage(UIImage(named: "play_big"), for: .normal)
                self.recordStatusLabel.text = "Tap to Record..."
                self.finishRecording(success: true)
            }else{
                button.isSelected = true
                activityIndicator.startAnimating()
                button.setImage(nil, for: .normal)
                self.recordStatusLabel.text = "Recording..."
                
                playButton.alpha = 0.5
                retakeButton.alpha = 0.5
                postButton.alpha = 0.5
                self.sliderLastTimeLabel.text = "0:00"
                playButton.isUserInteractionEnabled = false
                retakeButton.isUserInteractionEnabled = false
                audioSlider.isUserInteractionEnabled = false
                
                self.startRecording()
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


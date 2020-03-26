//
//  HomeFeedAudioCell.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 28/02/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView
import Mixpanel
class HomeFeedAudioCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var audioTitleLabel: UILabel!
    
    @IBOutlet weak var sepreatorLabel: UILabel!
    
    @IBOutlet weak var waveformView: SCSiriWaveformView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet weak var cellTypeIndicatorImage: UIImageView!
    
    @IBOutlet weak var audioContainerView: UIView!
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var progressViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    var session = AVAudioSession.sharedInstance()
    
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var clickableButton: UIButton!
    
    @IBOutlet weak var sliderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var soundButton: UIButton!
    
    @IBOutlet weak var viewContainer: UIView!
    
    var audioPlayer: AVAudioPlayer!
    var url:String!
    
    var timer: Timer?
    
    
    override func awakeFromNib() {
        usernameLabel.textColor = UIColor(red: 0.632, green: 0.803, blue: 1, alpha: 0.6)
        commentLabel.textColor = UIColor(red: 0.632, green: 0.803, blue: 1, alpha: 0.6)
        cellTypeIndicatorImage.image = UIImage(named: "audioIcon")
        
        self.waveformView.primaryWaveLineWidth = 1.0
        self.waveformView.secondaryWaveLineWidth = 1.0

        self.indicatorContainerView.isHidden = true

        audioSlider.transform = CGAffineTransform(scaleX: 1, y: 6)

        self.sliderHeightConstraint.constant = 0.01
        self.sepreatorLabel.isHidden = false
        self.waveformView.isHidden = true
        
        audioSlider.setThumbImage(UIImage(named: "Line"), for: .normal)
        self.audioSlider.maximumValue = 0
        self.progressView.isHidden = false
        self.progressLabel.isHidden = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
            self.audioSlider.addGestureRecognizer(tapGestureRecognizer)
        

        self.progressViewConstraint.constant = -(self.waveformView.frame.size.width)
        self.progressLabel.center = self.audioSlider.thumbCenterX
        
        self.sepreatorLabel.isHidden = true
    }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        self.cellButtonAction(self.clickableButton)
    }
    
    @IBAction func muteButtonAction(_ sender: Any) {
            let  button = sender as! UIButton
        
        if audioPlayer != nil {
            if button.isSelected {
                      audioPlayer.volume = 1
                      cellTypeIndicatorImage.image = UIImage(named: "umute")
                      button.isSelected = false

                  }else{
                      
                      audioPlayer.volume = 0
                      cellTypeIndicatorImage.image = UIImage(named: "mute")
                      button.isSelected = true
                  }
        }
            
      
        
    }
    
    @IBAction func cellButtonAction(_ sender: Any) {
       
        
        let button = sender as! UIButton
               if button.isSelected {
                   button.isSelected = false
                   audioPlayer.pause()
                
               }else{
                   button.isSelected = true
                   if audioPlayer == nil{
                    AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
                        audioPlayer.stop()
                    }
                    AppDelegate.currentAudioPlayer.removeAll()
                       downloadFileFromURL(url: self.url)
                   }else{
                    
                    self.commentButton.isHidden = false
                    self.soundButton.setBackgroundImage(UIImage(named: "umute"), for: .normal)
                    
                    Mixpanel.mainInstance().track(event: "Audio Play",
                    properties: ["Screen" : "HomeFeed"])
                    
                       audioPlayer.play()
                   }
               }
        
        self.sepreatorLabel.isHidden = true
//        self.downloadFileFromURL(url: self.url!)
        
    }
    
    // MARK:- Private Method
    // MARK:-
    
    
    func downloadFileFromURL(url:String){
        
        
        DispatchQueue.main.async {
                   
                   self.indicatorContainerView.isHidden = false
                   self.activityIndicator.isHidden = false
                   self.activityIndicator.startAnimating()
               }
        let tpURL = url.replacingOccurrences(of: " ", with: "")
        let tempUrl = URL(string: tpURL)
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(tempUrl!.lastPathComponent)
        print(destinationUrl)
        
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destinationUrl.path){
            
            DispatchQueue.main.async {
                self.indicatorContainerView.isHidden = true
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()

            }

            self.prepareAudioPlayer(url: destinationUrl)
        }else{
            
//            DispatchQueue.main.async {
//                self.indicatorContainerView.isHidden = false
//                self.activityIndicator.isHidden = false
//                self.activityIndicator.startAnimating()
//            }
//
            
            
            var downloadTaskSeesion:URLSessionDownloadTask
            downloadTaskSeesion = URLSession.shared.downloadTask(with: tempUrl!) { (url, response, error ) in
                if error == nil {
                    
                    DispatchQueue.main.async {
                        self.indicatorContainerView.isHidden = true
                        self.activityIndicator.stopAnimating()

                    }
                    do {
                        // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: url!, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    self.prepareAudioPlayer(url: destinationUrl)
                }
            }
            downloadTaskSeesion.resume()
        }
        
    }
    
    
    func prepareAudioPlayer(url:URL){
        if audioPlayer == nil {
            do{
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer.delegate = self
                
                DispatchQueue.main.async {
                    
                    self.waveformView.isHidden = false

                    self.audioPlayer.isMeteringEnabled = true
                    self.audioSlider.value = 0.0
                    self.audioSlider.maximumValue =  Float(self.audioPlayer.duration)
                    self.timer = Timer.scheduledTimer(timeInterval:0.01, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.timer!, forMode: .common)
                    
                    do {
                        try self.session.setCategory(.playback , mode: .default , options: .defaultToSpeaker)
                    }catch{
                        print(error)
                    }
                    
                    self.commentButton.isHidden = false
                    self.soundButton.setBackgroundImage(UIImage(named: "umute"), for: .normal)

                    
                    
                    Mixpanel.mainInstance().track(event: "Audio Play",
                                  properties: ["Screen" : "HomeFeed"])
                    
                    self.audioPlayer.prepareToPlay()
                    self.audioPlayer.play()
                    
                }
                
                AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
                    audioPlayer.stop()
                }
                
                AppDelegate.currentAudioPlayer.removeAll()
                AppDelegate.currentAudioPlayer.append(audioPlayer)
            }catch{
                print(error)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        
        if audioPlayer != nil {
            
            self.audioSlider.isUserInteractionEnabled = true
            
            audioPlayer.currentTime = TimeInterval(audioSlider.value)
            
            let widthView = self.contentView.frame.width
            let updatedValueForTrack = Float(audioPlayer.currentTime) / Float(audioPlayer.duration)
            
            let value = CGFloat(CGFloat(updatedValueForTrack) * CGFloat(widthView))
            print(value)
            print(audioSlider.value)
            self.progressViewConstraint.constant = value
        }
    }
    
    // MARK:- Delegates
    // MARK:-
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if audioPlayer != nil {
            print("called.. finish Playing")
            progressViewConstraint.constant = -(self.audioContainerView.frame.size.width)
            audioSlider.value = 0
            self.audioPlayer = nil
                  self.sepreatorLabel.isHidden = false
                  self.waveformView.isHidden = true
            self.timer?.invalidate()
            self.clickableButton.isSelected = false
            self.soundButton.setBackgroundImage(UIImage(named: "mute"), for: .normal)

        }
    }
    
    func normalizedPowerLevel(fromDecibels decibels: CGFloat) -> CGFloat {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        return CGFloat(powf((powf(10.0, Float(0.05 * decibels)) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0))
    }
}


extension UISlider {
    var thumbCenterX: CGPoint {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return CGPoint(x: thumbRect.midX, y: thumbRect.midY)
    }
}





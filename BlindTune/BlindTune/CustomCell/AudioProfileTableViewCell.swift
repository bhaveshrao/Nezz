//
//  AudioProfileTableViewCell.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 09/02/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AVFoundation

class AudioProfileTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var labelHeadLine: UILabel!
    @IBOutlet weak var labelAudioTitle: UILabel!
    @IBOutlet weak var labelSubHeading: UILabel!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var viewTrack: UIView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var audioCurrentTimeLabel: UILabel!
    @IBOutlet weak var audioLastTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    var session = AVAudioSession.sharedInstance()

    var audioPlayer: AVAudioPlayer!
    var url:String!
    
    var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.audioCurrentTimeLabel.text = "0:00"
        self.audioLastTimeLabel.text = "0:00"
        
        indicatorContainerView.isHidden = true
        self.audioSlider.maximumValue = 0

        self.imageWidthConstraint.constant = 0
        
        self.viewTrack.layer.borderColor = UIColor(displayP3Red: 11.0/255.0, green: 208.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor
        self.viewTrack.layer.borderWidth = 1.0
        self.viewTrack.layer.cornerRadius = 7
        self.viewTrack.clipsToBounds = true
        
        audioSlider.setThumbImage(UIImage(named: "toggle"), for: .normal)
        audioSlider.setThumbImage(UIImage(named: "toggle"), for: .highlighted)
        
        //        audioSlider.transform = CGAffineTransform(scaleX: 0.75, y: 0.85)
        
    }
    
    // MARK:- Private Method
    // MARK:-
    
    
    
    
    func downloadFileFromURL(url:String){
        
        
        let tempUrl = URL(string: url)
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(tempUrl!.lastPathComponent)
        print(destinationUrl)
        
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destinationUrl.path){
            self.prepareAudioPlayer(url: destinationUrl)
        }else{
            
            indicatorContainerView.isHidden = false
            activityIndicator.startAnimating()
            
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
                    self.audioSlider.value = 0.0
                    self.audioSlider.maximumValue =  Float(self.audioPlayer.duration)
                    self.audioLastTimeLabel.text = self.audioPlayer.duration.toMM_SS()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.timer!, forMode: .common)
                    self.playButton.isSelected  = true
                }
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
                self.audioPlayer.play()
                
            }catch{
                print(error)
            }
        }
    }
    
    
    @objc func updateSlider(){
        
        if audioSlider == nil{
            print("nil")
        }
        
        
        if audioPlayer != nil {
            self.audioCurrentTimeLabel.text = audioPlayer.currentTime.toMM_SS()
            let updatedValueForTrack = Float(audioPlayer.currentTime) / Float(audioPlayer.duration)
            let widthView = self.viewTrack.frame.width
            let value = CGFloat(CGFloat(updatedValueForTrack) * CGFloat(widthView))
            DispatchQueue.main.async {
                if self.audioSlider != nil && self.audioPlayer != nil {
                    self.audioSlider.value = Float(self.audioPlayer.currentTime)
                    self.imageWidthConstraint.constant = value
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    // MARK:- User Action
    // MARK:-
    
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
    
    @IBAction func playButtonClicked(_ sender: Any) {
        let button = sender as! UIButton
        if button.isSelected {
            button.isSelected = false
            audioPlayer.pause()
        }else{
            button.isSelected = true
            if audioPlayer == nil{
                downloadFileFromURL(url: self.url)
            }else{
                audioPlayer.play()
            }
        }
    }
    
    // MARK:- Delegates
    // MARK:-
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if audioPlayer != nil {
            print("called.. finish Playing")
            playButton.isSelected = false
            audioSlider.value = 0
            imageWidthConstraint.constant = 0
            self.audioCurrentTimeLabel.text = "0:00"
        }
        
    }
    
}


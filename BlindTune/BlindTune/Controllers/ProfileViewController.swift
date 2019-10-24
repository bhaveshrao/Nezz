//
//  ProfileViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 27/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//
import UIKit
import Firebase
import NVActivityIndicatorView
class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myPostLabel: UILabel!
    var lastPlayedIndex = -1
    var selectedIndex = -1
    let firebaseRefAudioPost = Database.database().reference(withPath: "AudioPosts")
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    var audioPostArray = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userNameLabel.text = ""

        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.tableViewBottomConstraint.constant = -(UIScreen.main.bounds.height - self.tableView.frame.origin.y)
        tableViewHeightConstraint.constant = 0

        indicatorContainerView.isHidden = false
        activityIndicator.startAnimating()
        
        self.userNameLabel.text = AppDelegate.user.username
        getAudioPostList()

    }
    
    // MARK:- Private Methode
    // MARK:-
    
    func getAudioPostList(){
        firebaseRefAudioPost.observe(.value) { (snapshot) in
            
            self.indicatorContainerView.isHidden = true
            self.activityIndicator.stopAnimating()
            
            if let tempArray = snapshot.value as? [String:Any] {
                self.audioPostArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
                self.audioPostArray = self.audioPostArray.sorted(by: { (value1, value2) -> Bool in
                    TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
                })
                
                self.audioPostArray = self.audioPostArray.filter({ (value) -> Bool in
                    value["userID"] as! String == AppDelegate.user.uid
                })
                
                DispatchQueue.main.async {
                    self.myPostLabel.text = "My Post " + "(\(self.audioPostArray.count))"
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func editProfileClicked(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
 
    @IBAction func backButtonClicked(_ sender: Any) {
        AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
            tempAudioPlayer.stop()
        }
        AppDelegate.currentAudioPlayer.removeAll()
        self.navigationController?.popViewController(animated: true)
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
    
    
    @IBAction func downbuttonClicked(_ sender: Any) {
        let button = sender as! UIButton
        if !button.isSelected {
            button.isSelected = true
            self.tableViewHeightConstraint.constant = UIScreen.main.bounds.height - self.tableView.frame.origin.y
            UIView.animate(withDuration: 0.3) {
                button.transform = CGAffineTransform(rotationAngle: CGFloat.pi )
                self.view.layoutIfNeeded()
            }
        }else{
            
            button.isSelected = false

            self.tableViewHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                button.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                self.view.layoutIfNeeded()
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "audioProfileCell") as! AudioProfileTableViewCell
        let tempDic = self.audioPostArray[indexPath.row]
        tableCell.labelAudioTitle.text = (tempDic["audioTitle"] as! String)
        tableCell.labelSubHeading.text = (tempDic["username"] as! String)
        tableCell.url = (tempDic["audioURL"]! as! String)
        tableCell.audioLastTimeLabel.text = (tempDic["timeDuration"] as! String)
        
        tableCell.audioPlayer = nil
        tableCell.audioSlider.value = 0
        tableCell.audioCurrentTimeLabel.text = "0:00"
        tableCell.imageWidthConstraint.constant = 0
        tableCell.playButton.isSelected = false
        tableCell.playButton.addTarget(self, action:#selector(ProfileViewController.playButtonClicked(sender:)) , for: .touchUpInside)
        tableCell.playButton.tag = indexPath.row
        tableCell.timer?.invalidate()
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
    

  
    
}

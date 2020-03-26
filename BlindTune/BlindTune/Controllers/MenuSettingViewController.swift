//
//  MenuSettingViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 16/03/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit

class ProfilePostProgressTableCell:UITableViewCell {
    
}

class MenuSettingViewController: UIViewController {
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonPosts: UIButton!
    @IBOutlet weak var buttonActivity: UIButton!
    @IBOutlet weak var buttonSetting: UIButton!
    
    @IBOutlet weak var tableViewSettings: UITableView!
    @IBOutlet weak var tableViewPosts: UITableView!
    
    var settingMenuArray = ["Username & Password","Push Notifications","Invite Someone","Rate This App","Contact Us"]
    
    var audioPostArray = [Dictionary<String, Any>]()
    var pageIndex = 1
    var flagForEmptyArray = false
    private let refreshControl = UIRefreshControl()
    var selectedRow = -1
    var lastSelectedRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelUsername.text = AppDelegate.user.username
        self.imageViewProfilePic.image = UIImage(named: "profileIcon")
        
        tableViewSettings.tableFooterView = UIView()
        
        self.tableViewSettings.isHidden = true
        self.tableViewPosts.isHidden = false
        refreshControl.tintColor = UIColor.white
        //        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Weather Data ...", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.getUserPosts()
    }
    
    
    @objc private func refreshWeatherData(_ sender: Any) {
        // Fetch Weather Data
        //        fetchWeatherData()
        self.pageIndex = 1
        self.flagForEmptyArray = false
        self.getUserPosts()
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        
        AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
            audioPlayer.stop()
        }
        
        AppDelegate.currentAudioPlayer.removeAll()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menuOptionAction(_ sender: Any) {
        
        AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
            audioPlayer.stop()
        }
        
        AppDelegate.currentAudioPlayer.removeAll()
        
        let button = sender as! UIButton
        
        self.tableViewSettings.isHidden = true
        self.tableViewPosts.isHidden = true
        
        self.labelLeadingConstraint.constant = button.frame.origin.x
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        if button.tag == 1 {
            self.tableViewPosts.isHidden = false
            
        }
        else if button.tag == 3 {
            self.tableViewSettings.isHidden = false
        }
        
    }
    
    
    // MARK:- Private Methode
    // MARK:-
    
    @objc func clickableTouchUp(sender:UIButton){
        
        selectedRow = sender.tag
        if lastSelectedRow != sender.tag {
            
            if lastSelectedRow != -1 {
                let indexPath = IndexPath(item: lastSelectedRow, section: 0)
                tableViewPosts.reloadRows(at: [indexPath], with: .none)
            }
            lastSelectedRow = sender.tag
        }
    }
    
    fileprivate func rateApp(appId: String) {
           let url = "itms-apps://itunes.apple.com/app/" + appId
               openUrl(url)
       }
       fileprivate func openUrl(_ urlString:String) {
           let url = URL(string: urlString)!
           if #available(iOS 10.0, *) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           } else {
               UIApplication.shared.openURL(url)
           }
       }
    
    func openLinkSharer(appId: String){
           
           if let name = NSURL(string: "https://itunes.apple.com/us/app/myapp/id" + appId + "?ls=1&mt=8") {
               let message = "Need an anonymous place to vent? Try the TooDeep app, a supporting and caring community with no judgement."
               let abc = "\n"
               let objectsToShare = [message,abc,name] as [Any]
               let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
               self.present(activityVC, animated: true, completion: nil)
           }
           else
           {
               // show alert for not available
           }
       }
    
    
    func getUserPosts()  {
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "0063b680-d2d0-5789-0ad3-857ed86670e1"
        ]
        
        var postData = Data()
        let dataArr  = ["page": "\(pageIndex)","limit": "5"]
        do {
            postData = try JSONSerialization.data(withJSONObject: dataArr, options: [])
        }catch{
            print(error)
        }
        
        
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://104.248.118.154:6004/audioPost/findUserPost/II09R1XCh9ayXonextEewig13n72")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        
        //        let request = NSMutableURLRequest(url: NSURL(string: Constant.baseURL + "/audioPost/findUserPost/\(AppDelegate.user._id)")! as URL,
        //                                          cachePolicy: .useProtocolCachePolicy,
        //                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                
                
                do {
                    let tempArray = try (JSONSerialization.jsonObject(with: data!, options : .allowFragments) as? [Dictionary<String,Any>])!
                    
                    
                    if tempArray.isEmpty {
                        self.flagForEmptyArray = true
                    }
                    if self.pageIndex == 1 {
                        self.audioPostArray = tempArray
                    }else{
                        self.audioPostArray.append(contentsOf: tempArray)
                        
                    }
                    print(self.audioPostArray)
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.tableViewPosts.reloadData()
                    }
                    
                    
                }catch {
                    print(error)
                }
                
                
                
                
                
            }
        })
        
        dataTask.resume()
    }
    
    
    
    
}

extension MenuSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewSettings {
            return 5
        }else if tableViewPosts == tableView{
            if !flagForEmptyArray {
                return audioPostArray.count + 1
            }
            return audioPostArray.count
        }else{
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewSettings{
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuSettingTableViewCell") as! MenuSettingTableViewCell
            cell.labelTitle.text = self.settingMenuArray[indexPath.row]
            cell.selectionStyle = .none
            return cell
            
        }else if tableViewPosts == tableView{
            
            if indexPath.row == audioPostArray.count {
                pageIndex = pageIndex + 1
                getUserPosts()
                return tableView.dequeueReusableCell(withIdentifier: "ProfilePostProgressTableCell", for: indexPath) as! ProfilePostProgressTableCell
            }else{
                
                let tempDic = self.audioPostArray[indexPath.row]
                
                if tempDic["postType"] as! String == "audio" {
                    let tableCell = tableView.dequeueReusableCell(withIdentifier: "ProfilePostAudioTableViewCell", for: indexPath) as! ProfilePostAudioTableViewCell
                    tableCell.selectionStyle = .none
                    
                    let tempDic = self.audioPostArray[indexPath.row]
                    tableCell.audioTitleLabel.text = (tempDic["audioTitle"] as! String)
                    tableCell.usernameLabel.text = (tempDic["username"] as! String)
                    tableCell.commentLabel.text = "\(tempDic["commentCount"] as! Int)"
                    tableCell.audioSlider.value = 0
                    tableCell.audioPlayer = nil
                    tableCell.sepreatorLabel.isHidden = false
                    tableCell.waveformView.isHidden = true
                    tableCell.clickableButton.isSelected = false
                    tableCell.progressViewConstraint.constant = -(tableCell.waveformView.frame.size.width)
                    
                    //                    tableCell.commentButton.tag = indexPath.row
                    
                    
                    tableCell.clickableButton.tag = indexPath.row
                    tableCell.clickableButton.addTarget(self, action: #selector(clickableTouchUp(sender:)), for: .touchUpInside)
                    //
                    tableCell.timer?.invalidate()
                    tableCell.url = (tempDic["audioURL"]! as! String)
                    
                    return tableCell
                }else{
                    
                    let tempDic = self.audioPostArray[indexPath.row]
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePostTextTableViewCell", for: indexPath) as! ProfilePostTextTableViewCell
                    
                    cell.messageLabel.text = (tempDic["audioName"] as! String)
                    cell.selectionStyle = .none
                    cell.commentLabel.text = "\(tempDic["commentCount"] as! Int)"
                    
                    cell.titleLabel.text = (tempDic["audioTitle"] as! String)
                    cell.usernameLabel.text = (tempDic["username"] as! String)
                    
                    
                    //                    cell.commentButton.tag = indexPath.row
                    
                    if self.selectedRow != indexPath.row{
                        cell.sepreatorLabel.isHidden = false
                        cell.messageLabel.isHidden = true
                    }else{
                        cell.sepreatorLabel.isHidden = true
                        cell.messageLabel.isHidden = false
                    }
                    
                    return cell
                }
            }
        }else{
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewSettings{
            return 60.0
        }else if tableView == self.tableViewPosts{
            
            
            if indexPath.row == audioPostArray.count {
                return 70
            }else {
                let tempDic = self.audioPostArray[indexPath.row]
                if indexPath.row == self.selectedRow {
                    if tempDic["postType"] as! String == "text" {
                        return UITableView.automaticDimension
                    }
                }
                if tempDic["postType"] as! String == "text" { return 147 }
                return 200
            }
            
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableViewPosts{
            self.lastSelectedRow = selectedRow
            if self.selectedRow == indexPath.row{
                self.selectedRow = -1
            }else{
                self.selectedRow = indexPath.row
            }
            tableView.reloadRows(at: [IndexPath(row: lastSelectedRow, section: 0)], with: .automatic)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }else if tableView == self.tableViewSettings {
            switch indexPath.row {
            case 0:
                break
            case 1:
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotificationSettingViewController") as! NotificationSettingViewController
                         self.navigationController?.pushViewController(controller, animated: true)
                break
            case 2:
                self.openLinkSharer(appId: "1451193612")
                break
            case 3:
                self.rateApp(appId: "1451193612")
                break
            case 4:
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
                self.navigationController?.pushViewController(controller, animated: true)
                
                break
            default:
                break
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == self.tableViewPosts{
            if indexPath.row == selectedRow {
                AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
                    tempAudioPlayer.stop()
                }
                AppDelegate.currentAudioPlayer.removeAll()
            }
        }
    }
    
    
}

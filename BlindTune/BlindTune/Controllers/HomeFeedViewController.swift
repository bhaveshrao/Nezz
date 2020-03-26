//
//  HomeFeedViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 26/02/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView
import Mixpanel

class ProgressTableCell:UITableViewCell {
    
}


class HomeFeedViewController: UIViewController{
    
    var selectedRow = -1
    var lastSelectedRow = -1
    var audioPostArray = [Dictionary<String, Any>]()
    var pageIndex = 1
    var flagForEmptyArray = false
    private let refreshControl = UIRefreshControl()
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        Mixpanel.mainInstance().identify(distinctId: AppDelegate.user._id)
        Mixpanel.mainInstance().people.set(properties: [ "$email": AppDelegate.user.email])
        Mixpanel.mainInstance().track(event: "Plan Selected",
                                      properties: ["Plan" : "Premium"])
        
        
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        //        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Weather Data ...", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        
        
        self.getAllAudioPost()
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @objc private func refreshWeatherData(_ sender: Any) {
        // Fetch Weather Data
        //        fetchWeatherData()
        self.pageIndex = 1
        self.flagForEmptyArray = false
        getAllAudioPost()
    }
    
    
    func getAllAudioPost(){
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "1a8e168f-709f-eb06-0b83-d8e52138129f"
        ]
        
        var postData = Data()
        let dataArr  = ["page": "\(pageIndex)","limit": "5"]
        do {
            postData = try JSONSerialization.data(withJSONObject: dataArr, options: [])
        }catch{
            print(error)
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://104.248.118.154:6004/audioPost/getAudioPost")! as URL,
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
                        self.tableView.reloadData()
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        })
        
        dataTask.resume()
        
        
    }
    
    @objc func clickableTouchUp(sender:UIButton){
        
        selectedRow = sender.tag
        if lastSelectedRow != sender.tag {
            
            if lastSelectedRow != -1 {
                let indexPath = IndexPath(item: lastSelectedRow, section: 0)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            lastSelectedRow = sender.tag
        }
    }
    
    @IBAction func plusButtonAction(_ sender: Any) {
        
        //        let alert = UIAlertController(title: "Alert!", message: "Work in Progress!", preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        //        self.present(alert, animated: true)
        
        //        shareTapped()
        
        
        let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "AudioTextlandingPageViewController") as! AudioTextlandingPageViewController
        AppDelegate.controllerType = "createPost"
        self.navigationController?.pushViewController(ctrl, animated: true)
        
    }
    @IBAction func menuButtonAction(_ sender: Any) {
        
        let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "MenuSettingViewController") as! MenuSettingViewController
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @IBAction func commentAudioButtonAction(_ sender: Any) {
        AppDelegate.currentAudioPlayer.forEach { (audioPlayer) in
            audioPlayer.stop()
        }
        
        AppDelegate.currentAudioPlayer.removeAll()
        let button = sender as! UIButton
        let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "CommentFeedViewController") as! CommentFeedViewController
        ctrl.postDic = self.audioPostArray[button.tag]
        ctrl.replyTypeString = "comment"
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    @IBAction func commentTextButtonAction(_ sender: Any) {
        let button = sender as! UIButton
        let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "CommentFeedViewController") as! CommentFeedViewController
        ctrl.postDic = self.audioPostArray[button.tag]
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
}

extension HomeFeedViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !flagForEmptyArray {
            return audioPostArray.count + 1
        }
        return audioPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == audioPostArray.count {
            pageIndex = pageIndex + 1
            getAllAudioPost()
            return tableView.dequeueReusableCell(withIdentifier: "progressTableCell", for: indexPath) as! ProgressTableCell
        }else{
            
            let tempDic = self.audioPostArray[indexPath.row]
            
            if tempDic["postType"] as! String == "audio" {
                let tableCell = tableView.dequeueReusableCell(withIdentifier: "audioFeedCell", for: indexPath) as! HomeFeedAudioCell
                tableCell.selectionStyle = .none
                
                let tempDic = self.audioPostArray[indexPath.row]
                tableCell.audioTitleLabel.text = (tempDic["audioTitle"] as! String)
                tableCell.usernameLabel.text = (tempDic["username"] as! String)
                //                tableCell.commentLabel.text = "\(tempDic["commentCount"] as! Int)"
                tableCell.audioSlider.value = 0
                tableCell.audioPlayer = nil
                tableCell.sepreatorLabel.isHidden = false
                tableCell.waveformView.isHidden = true
                tableCell.clickableButton.isSelected = false 
                tableCell.progressViewConstraint.constant = -(tableCell.waveformView.frame.size.width)
                
                tableCell.commentButton.tag = indexPath.row
                
                tableCell.sepreatorLabel.isHidden = true
                
                tableCell.clickableButton.tag = indexPath.row
                tableCell.clickableButton.addTarget(self, action: #selector(clickableTouchUp(sender:)), for: .touchUpInside)
                
                
                tableCell.commentButton.isHidden = true
                                
                tableCell.clickableButton.isHidden = true
                
                if self.selectedRow != indexPath.row{
                    tableCell.commentButton.isHidden = true
                    tableCell.viewContainer.isHidden = true
                    tableCell.clickableButton.isHidden = true

                }else{
                    tableCell.viewContainer.isHidden = false
                    tableCell.commentButton.isHidden = false
                    tableCell.clickableButton.isHidden = false

                }
                
                tableCell.timer?.invalidate()
                tableCell.url = (tempDic["audioURL"]! as! String)
                
                return tableCell
            }else{
                
                let tempDic = self.audioPostArray[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFeedCell", for: indexPath) as! HomeFeedTextCell
                cell.messageLabel.text = (tempDic["audioName"] as! String)
                cell.selectionStyle = .none
                //                cell.commentLabel.text = "\(tempDic["commentCount"] as! Int)"
                
                cell.titleLabel.text = (tempDic["audioTitle"] as! String)
                cell.usernameLabel.text = (tempDic["username"] as! String)
                
                cell.sepreatorLabel.isHidden = true
                
                cell.commentButton.isHidden = true
                cell.commentButton.tag = indexPath.row
                
                if self.selectedRow != indexPath.row{
                    cell.sepreatorLabel.isHidden = true
                    cell.messageLabel.isHidden = true
                    cell.commentButton.isHidden = true
                }else{
                    cell.sepreatorLabel.isHidden = true
                    cell.messageLabel.isHidden = false
                    cell.commentButton.isHidden = false
                    
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if indexPath.row == audioPostArray.count {
            return 100
        }else
        {
            let tempDic = self.audioPostArray[indexPath.row]
            if indexPath.row == self.selectedRow {
                if tempDic["postType"] as! String == "text" {
                    return UITableView.automaticDimension
                }else{
                    return 176
                }
            }
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.lastSelectedRow = selectedRow
        if self.selectedRow == indexPath.row{
            self.selectedRow = -1
        }else{
            self.selectedRow = indexPath.row
        }
        
        tableView.reloadRows(at: [IndexPath(row: lastSelectedRow, section: 0)], with: .automatic)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .none, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == selectedRow {
            AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
                tempAudioPlayer.stop()
            }
            AppDelegate.currentAudioPlayer.removeAll()
        }
    }
    
    func shareTapped() {
        let objectsToShare = [self.takeSnapShot() as Any] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    
    func takeSnapShot() -> UIImage{
        
        
        var image = UIImage();
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.tableView.contentSize.width, height:
            1217.29373138), false, UIScreen.main.scale)
        
        // save initial values
        let savedContentOffset = self.tableView.contentOffset;
        let savedFrame = self.tableView.frame;
        let savedBackgroundColor = self.tableView.backgroundColor
        
        // reset offset to top left point
        self.tableView.contentOffset = CGPoint(x: 0, y: 0);
        // set frame to content size
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.tableView.contentSize.width, height: 1217.29373138);
        // remove background
        self.tableView.backgroundColor = UIColor.clear
        
        // make temp view with scroll view content size
        // a workaround for issue when image on ipad was drawn incorrectly
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.contentSize.width, height: 1217.29373138));
        
        // save superview
        let tempSuperView = self.tableView.superview
        // remove scrollView from old superview
        self.tableView.removeFromSuperview()
        // and add to tempView
        tempView.addSubview(self.tableView)
        
        // render view
        // drawViewHierarchyInRect not working correctly
        tempView.layer.render(in: UIGraphicsGetCurrentContext()!)
        // and get image
        image = UIGraphicsGetImageFromCurrentImageContext()!;
        
        // and return everything back
        tempView.subviews[0].removeFromSuperview()
        
        tempSuperView?.addSubview(self.tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingConstraint = NSLayoutConstraint(item: tableView as Any, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        
        let trailingConstraint = NSLayoutConstraint(item: tableView as Any, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        
        let topConstraint = NSLayoutConstraint(item: tableView as Any, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        
        let bottoomConstraint = NSLayoutConstraint(item: tableView as Any, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -83)
        
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottoomConstraint])
        
        // restore saved settings
        self.tableView.contentOffset = savedContentOffset;
        self.tableView.frame = savedFrame;
        self.tableView.backgroundColor = savedBackgroundColor
        
        UIGraphicsEndImageContext();
        
        return image
        
    }
}


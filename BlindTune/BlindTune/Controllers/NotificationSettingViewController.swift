//
//  NotificationSettingViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 07/03/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase



class  NotificationSettingTableViewCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var buttonDisclauser: UIButton!
    @IBOutlet weak var switchNotification: UISwitch!
}

class NotificationSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let firebaseRefPushNotificationSetting = Database.database().reference(withPath: "PushNotificationSetting")
    var pushSettings:PushNotificationSetting!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.getPushNotificationSetting()
        
    }
    
    func getPushNotificationSetting(){
        
        
        firebaseRefPushNotificationSetting.child(AppDelegate.user.uid).observe(.value) { (snapshot) in
            
            if let value =  snapshot.value as? [String:Any] {
            self.pushSettings = PushNotificationSetting(commentOnMyPost: value["commentOnMyPost"] as! Bool, nezzUpdate: value["nezzUpdate"] as! Bool, allPost:  value["allPost"] as! Bool, userId: AppDelegate.user.uid)
                self.tableView.reloadData()
            }
        }
    }

    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "notiSettingCell") as! NotificationSettingTableViewCell
        tableCell.buttonDisclauser.isHidden = true
        
        tableCell.switchNotification.tag = indexPath.row
        tableCell.switchNotification.addTarget(self, action: #selector(notificationSettingsChange(switchNoti:)), for: .valueChanged)
        
        if indexPath.row == 0{
            if pushSettings != nil {
                tableCell.switchNotification.isOn = self.pushSettings.commentOnMyPost
            }
            tableCell.labelTitle.text = "Comments On My Posts"
        }else if indexPath.row == 1{
            if pushSettings != nil {
                tableCell.switchNotification.isOn = self.pushSettings.nezzUpdate
            }
            tableCell.labelTitle.text = "Deep Updates"
        }else{
            if pushSettings != nil {
                tableCell.switchNotification.isOn = self.pushSettings.allPost
            }
            tableCell.labelTitle.text = "All Posts"
        }
        return tableCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    
    @objc func notificationSettingsChange(switchNoti:UISwitch)  {
        
        switch switchNoti.tag {
        case 0:
           if pushSettings != nil {
                self.pushSettings.commentOnMyPost = switchNoti.isOn
            }
            break
        case 1:
            if pushSettings != nil {
                self.pushSettings.nezzUpdate = switchNoti.isOn
            }
            break
        case 2:
            if pushSettings != nil {
                self.pushSettings.allPost = switchNoti.isOn
            }
            break
        default:
            break
        }
        if pushSettings != nil {
            firebaseRefPushNotificationSetting.child(AppDelegate.user.uid).setValue(pushSettings.toAnyObject())

        }
        
    }
    
}

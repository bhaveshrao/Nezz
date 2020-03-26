//
//  SettingViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 26/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class  SettingTableViewCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var buttonDisclauser: UIButton!
    @IBOutlet weak var switchNotification: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //audioSlider.transform = CGAffineTransform(scaleX: 0.75, y: 0.85)
        
    }
    
}

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
   
    var arrayTitle = ["Profile", "Invite Friends","I Need Help","Rate This App","Contact Us", "Settings", "Notification Settings", "Logout"]
    var arrayIcon = ["profile_icon", "invite_frnd","help", "rate","contact", "setting", "notification_gray",  "logout"]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppDelegate.isSkipClicked {
            arrayTitle.removeLast()
            arrayIcon.removeLast()

        }

        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingTableViewCell
        tableCell.labelTitle.text = arrayTitle[indexPath.row]
        tableCell.labelTitle.textColor = UIColor.black

        tableCell.selectionStyle = .none
        tableCell.switchNotification.isHidden = true
        tableCell.imageViewIcon.image = UIImage(named: arrayIcon[indexPath.row])
        return tableCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if AppDelegate.isSkipClicked {
            self.setLoginRestriction()
            return
        }
        
        
        switch indexPath.row {
        case 0:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break;
        case 1:
            self.openLinkSharer(appId: "1451193612")
            break;
        case 6:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotificationSettingViewController") as! NotificationSettingViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case 3:
            self.rateApp(appId: "1451193612")
            break;
        case 4:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break;
        case 5:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
    
            self.navigationController?.pushViewController(controller, animated: true)
            break;
        case 2:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NeedHelpViewController") as! NeedHelpViewController
            controller.resourceName = "Need_Help_Hotline"
            controller.pageTitle = "I Need Help"
            self.navigationController?.pushViewController(controller, animated: true)
            break;
        case 7:
            
            let alertVC = UIAlertController(title: "Alert!", message: "Are you sure you want to logout?", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Yes", style: .default) {
                (_) in
                do {
                    try Auth.auth().signOut()
                    UserDefaults.standard.removeObject(forKey: "LoggedInUser")
                    AppDelegate.delegateFlag  = 0
                    self.setLoginToRoot()
                }catch{
                    print(error)
                }
            }
            
            let alertActionCancel = UIAlertAction(title: "No", style: .cancel) {
                (_) in
            }
            
            
            alertVC.addAction(alertActionOkay)
            alertVC.addAction(alertActionCancel)

            self.present(alertVC, animated: true, completion: nil)
            
            
           
            break;
        default:
            break
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
    
    
    private func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(error.localizedDescription)")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- Private Methode
    // MARK:-
    
    
    func openEmailComposer(){
        
        let emailTitle = "I need help on"
        let toRecipents = ["Nezzhq@gmail.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setToRecipients(toRecipents)
        self.present(mc, animated: true, completion: nil)
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
}

//
//  ParentDashboardViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 26/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase

class ParentDashboardViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var labelNotificationCount: UILabel!
    @IBOutlet weak var buttonHome: UIButton!
    @IBOutlet weak var buttonAddPost: UIButton!
    @IBOutlet weak var buttonSetting: UIButton!
    @IBOutlet weak var imageViewActive: UIImageView!
    
    @IBOutlet weak var labelTitle: UILabel!
    let dataBaseRefReplyPost = Database.database().reference(withPath: "ReplyOnPost")
    var audioReplyPostArray = [Dictionary<String, Any>]()
    var notificationArray = [Dictionary<String, Any>]()
    
    var isBackClicked = false
    static var isFromViewDidAppear = false
    var controller:UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewContainer.clipsToBounds = true
        self.labelNotificationCount.layer.cornerRadius = 10
        self.labelNotificationCount.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentDashboardViewController.callHome), name: NSNotification.Name(rawValue: "callHome"), object: nil)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setNotificationCount), name: NSNotification.Name(rawValue: "setNotificationCount"), object: nil)
        
        //        if let notificationCount = UserDefaults.standard.value(forKey: "localNotificationCount") {
        //            UserDefaults.standard.set((notificationCount as! Int) +  UIApplication.shared.applicationIconBadgeNumber , forKey: "localNotificationCount")
        //
        //
        //            self.labelNotificationCount.isHidden = false
        //            self.labelNotificationCount.text = "\((notificationCount as! Int) +  UIApplication.shared.applicationIconBadgeNumber)"
        //
        //
        //        }else if UIApplication.shared.applicationIconBadgeNumber > 0 {
        //            UserDefaults.standard.set( UIApplication.shared.applicationIconBadgeNumber , forKey: "localNotificationCount")
        //
        //            self.labelNotificationCount.isHidden = false
        //                 self.labelNotificationCount.text = "\(  UIApplication.shared.applicationIconBadgeNumber)"
        //        }else{
        //            self.labelNotificationCount.isHidden = true
        //
        //        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        print(self.children)
        switch AppDelegate.delegateFlag {
        case 0:
            //            self.labelTitle.text = "Nezz"
            
            self.buttonHome.isSelected = true
            self.buttonAddPost.isSelected = false
            self.buttonSetting.isSelected = false
            
            self.imageViewActive.frame = CGRect(x: buttonHome.frame.origin.x, y: self.imageViewActive.frame.origin.y, width: buttonHome.frame.size.width, height: self.imageViewActive.frame.size.height)
            
            
            let isContain =  self.children.contains { (ctrl) -> Bool in
                ctrl.isKind(of: HomeViewController.classForCoder())
            }
            
            
            if !isContain {
                controller = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.addChild(controller)
                controller.view.frame = CGRect(x: 0, y: 0, width: self.viewContainer.frame.size.width, height: self.viewContainer.frame.size.height)
                self.viewContainer.addSubview(controller.view)
                controller.didMove(toParent: self)
                
            }
            
            
            
            break
        case 1:
            
            self.buttonHome.isSelected = false
            self.buttonAddPost.isSelected = true
            self.buttonSetting.isSelected = false
            
            
            //            self.labelTitle.text = "Add Post"
            
            self.imageViewActive.frame = CGRect(x: buttonAddPost.frame.origin.x, y: self.imageViewActive.frame.origin.y, width: buttonAddPost.frame.size.width, height: self.imageViewActive.frame.size.height)
            
            let isContain =  self.children.contains { (ctrl) -> Bool in
                ctrl.isKind(of: AddPostViewController.classForCoder())
            }
            
            if !isContain {
                
                controller = self.storyboard?.instantiateViewController(withIdentifier: "AddPostViewController") as! AddPostViewController
                self.addChild(controller)
                controller.view.frame = CGRect(x: 0, y: 0, width: self.viewContainer.frame.size.width, height: self.viewContainer.frame.size.height)
                self.viewContainer.addSubview(controller.view)
                controller.didMove(toParent: self)
            }
            
            
            break
        case 2:
            
            self.buttonHome.isSelected = false
            self.buttonAddPost.isSelected = false
            self.buttonSetting.isSelected = true
            
            //            self.labelTitle.text = "More"
            
            self.imageViewActive.frame = CGRect(x: buttonSetting.frame.origin.x, y: self.imageViewActive.frame.origin.y, width: buttonSetting.frame.size.width, height: self.imageViewActive.frame.size.height)
            
            
            let isContain =  self.children.contains { (ctrl) -> Bool in
                ctrl.isKind(of: SettingViewController.classForCoder())
            }
            
            if !isContain {
                controller = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
                self.addChild(controller)
                controller.view.frame = CGRect(x: 0, y: 0, width: self.viewContainer.frame.size.width, height: self.viewContainer.frame.size.height)
                self.viewContainer.addSubview(controller.view)
                controller.didMove(toParent: self)
            }
            break
        default:
            break;
        }
        
        
        ParentDashboardViewController.isFromViewDidAppear = true
        
        
        if !AppDelegate.isSkipClicked {
            
            let dataBaseRefUser = Database.database().reference(withPath: "Users")
            
            let tempD =    ["email": AppDelegate.user.email,
                             "password": "",
                             "username": AppDelegate.user.username,
                             "deviceId": Messaging.messaging().fcmToken!,
                             "uid" : AppDelegate.user.uid,
                             "badge" : 0
                ] as [String : Any]
            let childRef = dataBaseRefUser.child(AppDelegate.user.uid)
            childRef.setValue(tempD)
            
        }
     
    self.chekcForNotification()

    }
    
    //MARK:- User Action
    //MARK:-
    
    
    @IBAction func notificationButtonClicked(_ sender: Any) {
        
        UserDefaults.standard.removeObject(forKey: "localNotificationCount")
        self.labelNotificationCount.isHidden =  true
        self.labelNotificationCount.text = "0"
        AppDelegate.localNotificationCount = -1
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if AppDelegate.isSkipClicked {
            self.setLoginRestriction()
            return
        }
        
        let  notiController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(notiController, animated: true)
    }
    
    @IBAction func bottomOptions_Clicked(_ sender: Any) {
        
        
        
        
        
        let button = sender as! UIButton
        
        
        if button.tag == 1{
            if AppDelegate.isSkipClicked {
                self.setLoginRestriction()
                return
            }
        }
        
        if button.tag != AppDelegate.delegateFlag {
            
            self.buttonHome.isSelected = false
            self.buttonAddPost.isSelected = false
            self.buttonSetting.isSelected = false
            
            
            
            if !controller.isKind(of: HomeViewController.classForCoder()){
                
                controller.willMove(toParent: nil)
                controller.view.removeFromSuperview()
                controller.removeFromParent()
            }
            
            
            AppDelegate.currentAudioPlayer.forEach { (tempAudioPlayer) in
                tempAudioPlayer.stop()
            }
            AppDelegate.currentAudioPlayer.removeAll()
            
            
            UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseInOut, animations: {
                DispatchQueue.main.async {
                    self.imageViewActive.frame = CGRect(x: button.frame.origin.x, y: self.imageViewActive.frame.origin.y, width: button.frame.size.width, height: self.imageViewActive.frame.size.height)
                }
            }, completion: nil)
            
            
            if button.isSelected {
                button.isSelected = false
            }else{
                button.isSelected = true
            }
            
            switch button.tag {
            case 0:
                //            self.labelTitle.text = "Nezz"
                
                controller = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.addChild(controller)
                controller.view.frame = CGRect(x: 0, y: 0, width: self.viewContainer.frame.size.width, height: self.viewContainer.frame.size.height)
                self.viewContainer.addSubview(controller.view)
                controller.didMove(toParent: self)
                AppDelegate.delegateFlag  = 0
                
                break;
            case 1:
                
                //            self.labelTitle.text = "Add Post"
                controller = self.storyboard?.instantiateViewController(withIdentifier: "AddPostViewController") as! AddPostViewController
                self.addChild(controller)
                controller.view.frame = CGRect(x: 0, y: 0, width: self.viewContainer.frame.size.width, height: self.viewContainer.frame.size.height)
                self.viewContainer.addSubview(controller.view)
                controller.didMove(toParent: self)
                
                AppDelegate.delegateFlag = 1
                
                break;
            case 2:
                
                //            self.labelTitle.text = "More"
                
                controller = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
                self.addChild(controller)
                controller.view.frame = CGRect(x: 0, y: 0, width: self.viewContainer.frame.size.width, height: self.viewContainer.frame.size.height)
                self.viewContainer.addSubview(controller.view)
                controller.didMove(toParent: self)
                
                AppDelegate.delegateFlag = 2
                
                break;
            default:
                break;
            }
            
        }
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
    
    func setLoginToRoot()  {
        
        AppDelegate.appDelegate().window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController:UIViewController
        initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginNav")
        AppDelegate.appDelegate().window?.rootViewController = initialViewController
        AppDelegate.appDelegate().window?.makeKeyAndVisible()
    }
    
    
    
    //MARK:- Privat Methode
    //MARK:-
    
    @objc func callHome()  {
        //        self.labelTitle.text = "Nezz"
        
        self.buttonHome.isSelected = true
        self.buttonAddPost.isSelected = false
        self.buttonSetting.isSelected = false
        
        AppDelegate.delegateFlag = 0
        
        self.imageViewActive.frame = CGRect(x: buttonHome.frame.origin.x, y: self.imageViewActive.frame.origin.y, width: buttonHome.frame.size.width, height: self.imageViewActive.frame.size.height)
        
        controller = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.addChild(controller)
        controller.view.frame = CGRect(x: 0, y: 0, width: self.viewContainer.frame.size.width, height: self.viewContainer.frame.size.height)
        self.viewContainer.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        
    }
    
    
    @objc func setNotificationCount(){
        
        UserDefaults.standard.removeObject(forKey: "localNotificationCount")
        self.labelNotificationCount.isHidden =  true
        self.labelNotificationCount.text = "0"
        AppDelegate.localNotificationCount = -1
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        
        //        if let notificationCount = UserDefaults.standard.value(forKey: "localNotificationCount") {
        //            self.labelNotificationCount.isHidden = false
        //            self.labelNotificationCount.text = "\(notificationCount)"
        //        }else{
        //            self.labelNotificationCount.isHidden = true
        //        }
    }
    
    func  chekcForNotification(){
        
        if !AppDelegate.isSkipClicked {
            
            dataBaseRefReplyPost.observe(.value) { (snapshot) in
                
                //            self.indicatorContainerView.isHidden = true
                //            self.activityIndicator.stopAnimating()
                //
                
                if let tempArray = snapshot.value as? [String:Any] {
                    self.audioReplyPostArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
                }
                
                self.notificationArray = self.audioReplyPostArray.filter({ (replyOnPost) -> Bool in
                    replyOnPost["replyTo"] as! String == AppDelegate.user.uid
                })
                
                
                self.notificationArray = self.notificationArray.sorted(by: { (value1, value2) -> Bool in
                              TimeInterval(value1["timeCreated"] as! Double) >   TimeInterval(value2["timeCreated"] as! Double)
                })
                
                if abs(self.notificationArray.count - AppDelegate.localNotificationCount) != 0 {
                    
                    let tempvalue = self.notificationArray.first
                    if tempvalue!["replyBy"] as! String == tempvalue!["replyTo"] as! String {
                        return
                    }
                }
                
                
                if AppDelegate.localNotificationCount == -1 {
                    AppDelegate.localNotificationCount = self.notificationArray.count
                    
                    if let notificationCount = UserDefaults.standard.value(forKey: "localNotificationCount") {
                        self.labelNotificationCount.isHidden = false
                        self.labelNotificationCount.text = "\((notificationCount as! Int) + UIApplication.shared.applicationIconBadgeNumber)"
                    }else if  UIApplication.shared.applicationIconBadgeNumber > 0 {
                        
                        UserDefaults.standard.set( UIApplication.shared.applicationIconBadgeNumber , forKey: "localNotificationCount")
                        
                        self.labelNotificationCount.isHidden = false
                        self.labelNotificationCount.text = "\(  UIApplication.shared.applicationIconBadgeNumber )"
                        
                        UIApplication.shared.applicationIconBadgeNumber = 0 

                    }
                    
                }else{
                    
                    if abs(self.notificationArray.count - AppDelegate.localNotificationCount) != 0 {
                        
                        self.labelNotificationCount.isHidden = false
                        
                        
                        if let notificationCount = UserDefaults.standard.value(forKey: "localNotificationCount") {
                            
                            
                            if UIApplication.shared.applicationIconBadgeNumber > 0 {
                                
                                UserDefaults.standard.set( UIApplication.shared.applicationIconBadgeNumber  + (notificationCount as! Int), forKey: "localNotificationCount")
                                
                                self.labelNotificationCount.isHidden = false
                                self.labelNotificationCount.text = "\(  UIApplication.shared.applicationIconBadgeNumber  + (notificationCount as! Int) )"
                                
                                UIApplication.shared.applicationIconBadgeNumber = 0
                            }else{
                                
                                if !(ParentDashboardViewController.isFromViewDidAppear) {
                                    UserDefaults.standard.set((notificationCount as! Int) + UIApplication.shared.applicationIconBadgeNumber + 1, forKey: "localNotificationCount")
                                                              
                                                              self.labelNotificationCount.text = "\((notificationCount as! Int) + UIApplication.shared.applicationIconBadgeNumber + 1)"
                                }else{
                                    
                                    UserDefaults.standard.set((notificationCount as! Int) + UIApplication.shared.applicationIconBadgeNumber, forKey: "localNotificationCount")
                                                              self.labelNotificationCount.text = "\((notificationCount as! Int) + UIApplication.shared.applicationIconBadgeNumber)"
                                    
                                    ParentDashboardViewController.isFromViewDidAppear = false
                                }
                                
                          
                                
                                
                                self.labelNotificationCount.isHidden = false
                                
                                
                            }
                        }else{
                            
                            
                            if UIApplication.shared.applicationIconBadgeNumber > 0 {
                                
                                UserDefaults.standard.set( UIApplication.shared.applicationIconBadgeNumber  , forKey: "localNotificationCount")
                                
                                self.labelNotificationCount.isHidden = false
                                
                                self.labelNotificationCount.text = "\(  UIApplication.shared.applicationIconBadgeNumber   )"
                                UIApplication.shared.applicationIconBadgeNumber  = 0
                                
                            }else{
                                UserDefaults.standard.set(abs(self.notificationArray.count - AppDelegate.localNotificationCount) , forKey: "localNotificationCount")
                                                        self.labelNotificationCount.isHidden = false
                                                        self.labelNotificationCount.text = "\( abs(self.notificationArray.count - AppDelegate.localNotificationCount))"
                                
                                ParentDashboardViewController.isFromViewDidAppear = false

                            }
                   
                        }
                        
                    }
                    
                }
                
                print("=====================\(self.notificationArray.count)")
                
            }
        }
    }
    
    
    
    
}

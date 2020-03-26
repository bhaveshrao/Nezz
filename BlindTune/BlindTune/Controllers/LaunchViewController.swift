//
//  LaunchViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 25/11/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
         if UserDefaults.standard.object(forKey: "LoggedInUser") == nil {
                    
                    let firebaseRefUsers = Database.database().reference(withPath: "Users")
                    firebaseRefUsers.observe(.value) { (snapshot) in
                        
//                        if let tempArray = snapshot.value as? [String:Any] {
//                            self.deviceIdArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
//                            self.deviceIdArray = self.deviceIdArray.filter({ (value) -> Bool in
//                                value["deviceId"] as! String == UIDevice.current.identifierForVendor!.uuidString
//                            })
//                        }
                        if !AppDelegate.isUserRegistered {
        //                    self.setRootController(isFirstTimeUser: self.deviceIdArray.isEmpty)
                            AppDelegate.isSkipClicked = true
                            self.perform(#selector(self.setHomeToRoot), with: nil, afterDelay: 2.0)
                        }
                    }
                }else{
                    
                    AppDelegate.isSkipClicked = false

                    AppDelegate.user = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "LoggedInUser") as! Data) as! User)
            self.perform(#selector(self.setHomeToRoot), with: nil, afterDelay: 2.0)
                }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func setHomeToRoot()  {
          
        AppDelegate.appDelegate().window = UIWindow(frame: UIScreen.main.bounds)
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let initialViewController:UIViewController
          initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeNav")
           AppDelegate.appDelegate().window?.rootViewController = initialViewController
           AppDelegate.appDelegate().window?.makeKeyAndVisible()
      }
    
}

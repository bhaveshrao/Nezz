//
//  InitialViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 05/03/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit
import Foundation
import Firebase

@available(iOS 13.0, *)
class InitialViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func continueAction(_ sender: Any) {
        self.continueButton.setTitle("", for: .normal)
        self.activityIndicator.isHidden = false
        self.perform(#selector(self.anonymouslyLogin), with: self, afterDelay: 5.0)
    }
    
    @objc func anonymouslyLogin() {
    
         do{
             try Auth.auth().signOut()
         }catch{
             print(error)
         }
        Auth.auth().signInAnonymously(completion: { [weak self](authDataResult: AuthDataResult?, error) in

                if let error = error { return }

                guard let _ = authDataResult?.user.uid else { return }
            })
        
         
         if UserDefaults.standard.object(forKey: "LoggedInUser") == nil {
             self.getUserId()
         }else{
             
              AppDelegate.user = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "LoggedInUser") as! Data) as! User)
             
             let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "HomeFeedViewController") as! HomeFeedViewController
             self.navigationController?.pushViewController(ctrl, animated: true)
         }

    }
    
    func getUserId(){
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "26b75fd2-0842-7f6b-a154-4c59be26c784"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://104.248.118.154:6004/user/create/")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                do {
                    let tempDic = try (JSONSerialization.jsonObject(with: data!, options : .allowFragments)) as? [String:Any]
                    let user = User(_id: tempDic!["_id"] as! String, email: "", username: tempDic!["username"] as! String, isVerified: tempDic!["isVerified"] as! Bool)
                    AppDelegate.user = user
                    
                      let data = NSKeyedArchiver.archivedData(withRootObject: AppDelegate.user)
                      UserDefaults.standard.set(data, forKey: "LoggedInUser")
                      UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.continueButton.setTitle("Continue", for: .normal)
                        
                        let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "HomeFeedViewController") as! HomeFeedViewController
                        self.navigationController?.pushViewController(ctrl, animated: true)
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        })
        
        dataTask.resume()
    }
}

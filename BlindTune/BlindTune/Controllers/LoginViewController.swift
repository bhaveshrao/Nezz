//
//  LoginViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 25/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var logInTextFields: [UITextField]!
    @IBOutlet var errorAndSuccessLabels: [UILabel]!

    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    var userArray = [Dictionary<String, Any>]()

    var firebaseRefUsers:DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        indicatorContainerView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        firebaseRefUsers = Database.database().reference(withPath: "Users")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        logInTextFields.forEach { (textField) in
            textField.resignFirstResponder()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.subviews.forEach { (view) in
            if view.isKind(of: UILabel.classForCoder()){
                (view as! UILabel).textColor = UIColor.black
            }
        }
        
        self.logInTextFields[0].text = "bhaveshr970@gmail.com"
        self.logInTextFields[1].text = "123456"
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        
//        NotificationCenter.default.removeObserver(self)
//    }
    
    // MARK:- Private Methode
    // MARK:-
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 50
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    func setHomeToRoot()  {
        
       AppDelegate.appDelegate().window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController:UIViewController
        initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeNav")
         AppDelegate.appDelegate().window?.rootViewController = initialViewController
         AppDelegate.appDelegate().window?.makeKeyAndVisible()
    }
    
    func callForgotPassword(email:String){
        
        if AppDelegate.reachablity.connection == .none {
            
            let alerController = UIAlertController(title: "Alert!", message: "No Internet Connection!!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alerController.addAction(alertAction)
            self.present(alerController, animated: true, completion: nil)
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if error == nil {
                
                let alerController = UIAlertController(title: "Success!", message: "Password reset link has been sent to your emaill", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alerController.addAction(alertAction)
                self.present(alerController, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK:- User Actions
    // MARK:-
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        if AppDelegate.isFirstTime{
            self.navigationController?.popViewController(animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
       
    }
    @IBAction func skipClicked(_ sender: Any) {
        
        if AppDelegate.reachablity.connection == .none {
            
            let alerController = UIAlertController(title: "Alert!", message: "No Internet Connection!!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alerController.addAction(alertAction)
            self.present(alerController, animated: true, completion: nil)
            return
        }
        
        AppDelegate.isSkipClicked = true
      
        self.setHomeToRoot()
        
    }
    
    
    @IBAction func loginClicked(_ sender: Any) {
        
        logInTextFields.forEach { (textField) in
            textField.resignFirstResponder()
        }
        
        if (logInTextFields[0].text?.isEmpty)! || !(logInTextFields[0].text?.isValidEmail())!{
            logInTextFields[0].shake()
            return
        }else if (logInTextFields[1].text?.isEmpty)! {
            logInTextFields[1].shake()
            return
        }
        
    
        
        if AppDelegate.reachablity.connection == .none {
            
            let alerController = UIAlertController(title: "Alert!", message: "No Internet Connection!!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alerController.addAction(alertAction)
            self.present(alerController, animated: true, completion: nil)
            return
        }
        
        indicatorContainerView.isHidden = false
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail:self.logInTextFields[0].text! , password: self.logInTextFields[1].text!, completion: { (result, error) in
            if error == nil {
                print(result!)
                
                
                self.indicatorContainerView.isHidden = true
                self.activityIndicator.stopAnimating()
                
                if !(Auth.auth().currentUser?.isEmailVerified)! {
                    
                    let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(self.logInTextFields[0].text!).", preferredStyle: .alert)
                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                        (_) in
                        Auth.auth().currentUser!.sendEmailVerification(completion: nil)
                    }
                    let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    
                    alertVC.addAction(alertActionOkay)
                    alertVC.addAction(alertActionCancel)
                    self.present(alertVC, animated: true, completion: nil)
                    
                    return
                    
                }
                
                
                self.firebaseRefUsers.child((result?.user.uid)!).observe(.value, with: { (snapshot) in
                    
                    if let _ =  snapshot.value as? NSNull {
                        let alertVC = UIAlertController(title: "Error", message: "User Not Found!!", preferredStyle: .alert)
                        let alertActionCancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertVC.addAction(alertActionCancel)
                        self.present(alertVC, animated: true, completion: nil)
                        return
                    }
                    
                
                 
                    
                    let tempDic = snapshot.value as! [String:String];
                    AppDelegate.user = User(uid: (result?.user.uid)!, email: (result?.user.email)!, username: tempDic["username"]!)
                    
                    
                    let childRef = self.firebaseRefUsers.child((result?.user.uid)!)
                    let tempUser = User(uid: (result?.user.uid)!, email: (result?.user.email)!, username: tempDic["username"]!)
                    childRef.setValue(tempUser.toAnyObject())
                    
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: AppDelegate.user)
                    UserDefaults.standard.set(data, forKey: "LoggedInUser")
                    UserDefaults.standard.synchronize()
                    
                    AppDelegate.isUserRegistered = true
                    
                    
                    return

                })
                
                AppDelegate.isSkipClicked = false

                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ParentDashboardViewController") as! ParentDashboardViewController
                self.navigationController?.pushViewController(controller, animated: true)
                
            }else{
                
                self.indicatorContainerView.isHidden = true
                self.activityIndicator.stopAnimating()

                self.logInTextFields[0].shake()
                self.logInTextFields[1].shake()

            }
            
        })
        
    }
    @IBAction func forgetPasswordClicked(_ sender: Any) {
        
        
    
        
        let alertController = UIAlertController(title: "Forgot Password?", message: "Enter your email here!", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
        }
        let saveAction = UIAlertAction(title: "Send", style: .destructive, handler: { alert -> Void in
            let emailField = alertController.textFields![0] as UITextField
            if (emailField.text?.isEmpty)! || !(emailField.text?.isValidEmail())! {
                
                DispatchQueue.main.async {
                    
                    let alertVC = UIAlertController(title: "Error", message: "Please insert correct email.", preferredStyle: .alert)
                    let alertActionCancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertVC.addAction(alertActionCancel)
                    self.present(alertVC, animated: true, completion: nil)
                }

                
            }else{
                
                let firebaseRefUsers = Database.database().reference(withPath: "Users")
                firebaseRefUsers.observe(.value) { (snapshot) in
                    
                    if let tempArray = snapshot.value as? [String:Any] {
                        self.userArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
                        self.userArray = self.userArray.filter({ (value) -> Bool in
                            value["email"] as! String == emailField.text!
                        })
                    }
                    if self.userArray.isEmpty {
                        
                        DispatchQueue.main.async {
                            
                            let alertVC = UIAlertController(title: "Error", message: "User not found or Your email address has not yet been verified.", preferredStyle: .alert)
                            let alertActionCancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertVC.addAction(alertActionCancel)
                            self.present(alertVC, animated: true, completion: nil)
                        }

                        
                    }else{
                        self.callForgotPassword(email: emailField.text!)

                    }
                }
                
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
    
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK:- Delegate Method
    // MARK:-
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       if textField == logInTextFields[0] {
            
            if !(textField.text?.isEmpty)! && (textField.text?.isValidEmail())!{
                errorAndSuccessLabels[0].backgroundColor = UIColor(displayP3Red: 50.0/255.0, green: 111.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                
                return
                
            }else{
                errorAndSuccessLabels[0].backgroundColor = UIColor.lightGray
                return
            }
            
        }else if textField == logInTextFields[1]{
            
            if !(textField.text?.isEmpty)!{
                errorAndSuccessLabels[1].backgroundColor = UIColor(displayP3Red: 50.0/255.0, green: 111.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                return
                
            }else{
                errorAndSuccessLabels[1].backgroundColor = UIColor.lightGray
                return
            }
        }
    }

}

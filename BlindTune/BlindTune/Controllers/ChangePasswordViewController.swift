//
//  ChangePasswordViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 27/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var userArray = [Dictionary<String, Any>]()
    let firebaseRefUser = Database.database().reference(withPath: "Users")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.placeholder =  AppDelegate.user.email
        self.userNameTextField.text = AppDelegate.user.username
        // Do any additional setup after loading the view.
    }
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self .userNameTextField.resignFirstResponder()
    }

    // MARK: - Delegate
    // MARK: -
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: - Private Methode
    // MARK: -
    
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
    
    // MARK: - User Action
    // MARK: -
    @IBAction func udpateUsernameClicked(_ sender: Any) {
        
        
        if AppDelegate.reachablity.connection == .none {
            
            let alerController = UIAlertController(title: "Alert!", message: "No Internet Connection!!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alerController.addAction(alertAction)
            self.present(alerController, animated: true, completion: nil)
            return
        }
        
        
        let childRef = self.firebaseRefUser.child(AppDelegate.user.uid)
        let tempUser = User(uid: AppDelegate.user.uid, email: AppDelegate.user.email, username: self.userNameTextField.text!)
        AppDelegate.user = tempUser
        AppDelegate.isUserRegistered = true
        childRef.setValue(tempUser.toAnyObject())
        
        self.userNameTextField.resignFirstResponder()
        
        let data = NSKeyedArchiver.archivedData(withRootObject: AppDelegate.user)
        UserDefaults.standard.set(data, forKey: "LoggedInUser")
        UserDefaults.standard.synchronize()
        
        let alerController = UIAlertController(title: "Success!", message: "Congratulations!! Your username has been updated successfully", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alerController.addAction(alertAction)
        self.present(alerController, animated: true, completion: nil)
        
    }
    
    @IBAction func restPasswordButtonClicked(_ sender: Any) {
        
        self.callForgotPassword(email: self.emailTextField.placeholder!)

    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termsAndConditionButtonsClicked(_ sender: Any) {
        let button = sender as! UIButton
    
        switch button.tag {
        case 1:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NeedHelpViewController") as! NeedHelpViewController
            controller.resourceName = "Nezz_TERMS_of_Services"
            controller.pageTitle  = "Terms Of Services"

            self.navigationController?.pushViewController(controller, animated: true)
            break
        case 2:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NeedHelpViewController") as! NeedHelpViewController
            controller.resourceName = "Nezz_GDPR Cоmрlіаnсе Prіvасу Pоlісу"
            controller.pageTitle  = "Prіvасу Pоlісу"
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case 3:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NeedHelpViewController") as! NeedHelpViewController
            controller.resourceName = "Nezz Community Guideline"
            controller.pageTitle  = "Community Guidelines"
            self.navigationController?.pushViewController(controller, animated: true)
            break
        default:
            break
        }
    }
    

}

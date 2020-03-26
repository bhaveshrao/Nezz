//
//  SignupViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 25/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class SignupViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var ageConfirmationButton: UIButton!
    

    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet var signUpTextFields: [UITextField]!
    @IBOutlet var errorAndSuccessLabels: [UILabel]!
    @IBOutlet weak var popOverView: UIView!
    
    var ageConfirmationFlag = false
    let firebaseRefUser = Database.database().reference(withPath: "Users")
    let firebaseRefPushNotificationSetting = Database.database().reference(withPath: "PushNotificationSetting")

    @IBOutlet weak var signUpButtonBottomConstraint: NSLayoutConstraint!
    var lastEditedTextField:UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorContainerView.isHidden = true

        // Do any additional setup after loading the view.
        
      
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignupViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignupViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        ageConfirmationButton.layer.cornerRadius = 20
        ageConfirmationButton.layer.borderWidth = 2.0
        
        ageConfirmationButton.layer.borderColor = UIColor(displayP3Red: 50.0/255.0, green: 111.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        signUpTextFields.forEach { (textField) in
            textField.text = ""
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        signUpTextFields.forEach { (textField) in
            textField.resignFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
            if  signUpButtonBottomConstraint.constant == 151{
               signUpButtonBottomConstraint.constant = keyboardSize.height + 20
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
           signUpButtonBottomConstraint.constant = 151
    }
    
    // MARK:- User Actions
    // MARK:-
    
    @IBAction func loginClicked(_ sender: Any) {
        
        if AppDelegate.isFirstTime {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            self.navigationController?.pushViewController(controller!, animated: true)
            
        }else{
            self.navigationController?.popViewController(animated: true)

        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        signUpTextFields.forEach { (textField) in
            textField.resignFirstResponder()
        }
        
        if (signUpTextFields[0].text?.isEmpty)! {
           signUpTextFields[0].shake()
            return
        } else if (signUpTextFields[1].text?.isEmpty)! || !(signUpTextFields[1].text?.isValidEmail())!{
            signUpTextFields[1].shake()
            return
        }else if (signUpTextFields[2].text?.isEmpty)! || (signUpTextFields[2].text?.count)! < 6{
            signUpTextFields[2].shake()
            return
        }else if (signUpTextFields[3].text?.isEmpty)! || signUpTextFields[2].text != signUpTextFields[3].text {
            signUpTextFields[3].shake()
            return
        }else if !ageConfirmationFlag {
            ageConfirmationButton.shake()
            return
        }
        
       
       
        if AppDelegate.reachablity.connection == .none {
            
            let alerController = UIAlertController(title: "Alert!", message: "No Internet Connection!!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alerController.addAction(alertAction)
            self.present(alerController, animated: true, completion: nil)
            return
        }
        
        
        self.indicatorContainerView.isHidden = false
        self.activityIndicator.startAnimating()
        
        
        
        
//        Auth.auth().createUser(withEmail: signUpTextFields[1].text!, password: signUpTextFields[2].text!) { (authResult, error) in
//            if error == nil {
//                
//                AppDelegate.isUserRegistered = true
//                self.indicatorContainerView.isHidden = true
//                self.activityIndicator.stopAnimating()
//
//                Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
//                    
//                    let alert = UIAlertController(title: "Account Created", message: "Please verify your email by confirming the sent link.", preferredStyle: UIAlertController.Style.alert)
//                    
//                    
//                    
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
//                        if AppDelegate.isFirstTime {
//                            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//                            self.navigationController?.pushViewController(controller, animated: true)
//                        }else{
//                            self.navigationController?.popViewController(animated: true)
//                        }
//                    }))
//                    
//                    
//                    self.present(alert, animated: true, completion: nil)
//
//                })
//                
//                
//                Auth.auth().signIn(withEmail:self.signUpTextFields[1].text! , password: self.signUpTextFields[2].text!, completion: { (result, error) in
//                    if error == nil {
//                        
//                    
//                        
//                        let childRef = self.firebaseRefUser.child((result?.user._id)!)
//                        let tempUser = User(uid: (result?.user._id)!, email: (result?.user.email)!, username: self.signUpTextFields[0].text!)
//                        AppDelegate.user = tempUser
//                        childRef.setValue(tempUser.toAnyObject())
//                        let childPush = self.firebaseRefPushNotificationSetting.child((result?.user._id)!)
//                        let pushSetting = PushNotificationSetting(commentOnMyPost: true, nezzUpdate: true, allPost: true, userId: (result?.user._id)!)
//                        childPush.setValue(pushSetting.toAnyObject())
//                        
////                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ParentDashboardViewController") as! ParentDashboardViewController
////                        self.navigationController?.pushViewController(controller, animated: true)
//                        
//                    }
//                    
//                })
//            }else{
//                
//                self.indicatorContainerView.isHidden = true
//                self.activityIndicator.stopAnimating()
//
//            
//            let alert = UIAlertController(title: "Error!", message:(error?.localizedDescription)!, preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//        
//    }
}
    @IBAction func yesClicked(_ sender: Any) {
        ageConfirmationFlag = true

        self.popOverView.isHidden = true
        ageConfirmationButton.layer.borderColor = UIColor.green.cgColor
    }
    
    @IBAction func cancelPopClicked(_ sender: Any) {
        self.popOverView.isHidden = true
        ageConfirmationFlag = false
        
        let button = sender as! UIButton
        if button.tag == 1 {
         ageConfirmationButton.layer.borderColor = UIColor(red: 255.0/255.0, green: 78.0/255.0, blue:  78.0/255.0, alpha: 1).cgColor
        }
       
        
    }
    @IBAction func ageConfirmationButtonClicked(_ sender: Any) {
        self.popOverView.isHidden = false

        signUpTextFields.forEach { (textField) in
            textField.resignFirstResponder()
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
    
    func setHomeToRoot()  {
        
        AppDelegate.appDelegate().window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController:UIViewController
        initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeNav")
        AppDelegate.appDelegate().window?.rootViewController = initialViewController
        AppDelegate.appDelegate().window?.makeKeyAndVisible()
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
        default:
            break
        }
    }
    
    // MARK:- Delegate Method
    // MARK:-
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

       return true
        
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        lastEditedTextField = textField
        if textField == signUpTextFields[0] {
            
        if !(textField.text?.isEmpty)!{
            self.errorAndSuccessLabels[0].backgroundColor = UIColor(displayP3Red: 50.0/255.0, green: 111.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            return

        }else{
            errorAndSuccessLabels[0].backgroundColor = UIColor.lightGray
            return
        }
            
        }else if textField == signUpTextFields[1] {
            
            if !(textField.text?.isEmpty)! && (textField.text?.isValidEmail())!{
                errorAndSuccessLabels[1].backgroundColor = UIColor(displayP3Red: 50.0/255.0, green: 111.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
                return

            }else{
                errorAndSuccessLabels[1].backgroundColor = UIColor.lightGray
                return
            }
            
        }else if textField == signUpTextFields[2]{
            
            if !(textField.text?.isEmpty)!{
                errorAndSuccessLabels[2].backgroundColor = UIColor(displayP3Red: 50.0/255.0, green: 111.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                return

            }else{
                errorAndSuccessLabels[2].backgroundColor = UIColor.lightGray
                return
            }
        }else {
            
            if !(textField.text?.isEmpty)! && signUpTextFields[2].text == signUpTextFields[3].text {
                errorAndSuccessLabels[3].backgroundColor = UIColor(displayP3Red: 50.0/255.0, green: 111.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                return

            }else{
                errorAndSuccessLabels[3].backgroundColor = UIColor.lightGray
                return
            }
            
        }
    }

}


extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

extension UIView {
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 15, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 15, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}

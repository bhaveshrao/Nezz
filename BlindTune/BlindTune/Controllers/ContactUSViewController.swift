//
//  ContactUSViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 27/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase

class ContactUSViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldSubject: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomScrollConstraint: NSLayoutConstraint!
    
    let firebaseRefReportQueries = Database.database().reference(withPath: "ReportQueries")

    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        
        textView.text = "Type your message here..."
        textView.textColor = UIColor.lightGray
    
        
        self.textFieldEmail.text =  AppDelegate.user.email
        self.textFieldName.text = AppDelegate.user.username
        
        self.textFieldName.isUserInteractionEnabled = false
        self.textFieldEmail.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactUSViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactUSViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    // MARK:- User Actoin
    // MARK:-
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
    
        textView.resignFirstResponder()

        if (textFieldSubject.text?.isEmpty)! && ((textView.text.isEmpty) || textView.text == "Type your message here..." ){
            textView.shake()
            textFieldSubject.shake()
        }else if (textFieldSubject.text?.isEmpty)! {
            textFieldSubject.shake()
        }else if ((textView.text.isEmpty) || textView.text == "Type your message here..." ) {
            textView.shake()
        }else{
            
            let randomeInt = Int.random(in: 500...50000)
            let id = AppDelegate.user.uid + String(format: "%d", randomeInt)
            
            let reportQuerie = ["email":AppDelegate.user.email,"userId": AppDelegate.user.uid,"username":AppDelegate.user.username,"subject": textFieldSubject.text!,"query": textView.text!]
            self.firebaseRefReportQueries.child(id).setValue(reportQuerie)
           
            
            let alerController = UIAlertController(title: "Success!!", message: "Your queries has been recevied!!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
              
                self.textView.text = "Type your message here..."
                self.textView.textColor = UIColor.lightGray

                self.textFieldSubject.text = ""
                
            
                
            })
            alerController.addAction(alertAction)
            self.present(alerController, animated: true, completion: nil)
            
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
            if  self.bottomScrollConstraint.constant == 0{
                self.bottomScrollConstraint.constant = keyboardSize.height + 20
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
         self.bottomScrollConstraint.constant = 0
    }
    
    
 
    // MARK:- Delegate Methode
    // MARK:-
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.resignFirstResponder()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type your message here..."
            textView.textColor = UIColor.lightGray
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
    

    
    

}

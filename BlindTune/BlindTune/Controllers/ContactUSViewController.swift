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
        
        textView.text = "What do you need help with?"
        textView.textColor = UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)
        
        
        textFieldName.attributedPlaceholder = NSAttributedString(string: "Enter your email",
                                                                  attributes:
            [NSAttributedString.Key.foregroundColor:
                UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)])
        textFieldName.textColor = UIColor.white

    
        textFieldName.delegate = self

        
//        NotificationCenter.default.addObserver(self, selector: #selector(ContactUSViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ContactUSViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//
        // Do any additional setup after loading the view.
    }
    
    // MARK:- User Actoin
    // MARK:-
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
    
        textView.resignFirstResponder()

        if (textFieldSubject.text?.isEmpty)! && ((textView.text.isEmpty) || textView.text == "What do you need help with?" ){
            textView.shake()
            textFieldName.shake()
        }else if (textFieldSubject.text?.isEmpty)! {
            textFieldName.shake()
        }else if ((textView.text.isEmpty) || textView.text == "What do you need help with?" ) {
            textView.shake()
        }else{
            self.submitContactInfoToServer()
        }
    }
    
//    @objc func keyboardWillShow(notification: Notification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            print("notification: Keyboard will show")
//            if  self.bottomScrollConstraint.constant == 0{
//                self.bottomScrollConstraint.constant = keyboardSize.height + 20
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: Notification) {
//         self.bottomScrollConstraint.constant = 0
//    }
//
//
    
    
    func submitContactInfoToServer(){
        
        let headers = [
          "content-type": "application/json",
          "cache-control": "no-cache",
          "postman-token": "589434e5-0c07-ccc7-40fc-ebfda4b44fa4"
        ]
        let parameters = [
            "subject": self.textFieldEmail.text! as Any,
            "message": self.textView.text,
            "userId": AppDelegate.user._id
        ] as [String : Any]

        var postData = Data()

        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }catch {
            print(error)
        }

        let request = NSMutableURLRequest(url: NSURL(string: Constant.baseURL + "/contactUs/create/")! as URL,
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
           
            DispatchQueue.main.async {

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
        })

        dataTask.resume()
        
    }
    // MARK:- Delegate Methode
    // MARK:-
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.resignFirstResponder()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0) {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What do you need help with?"
            textView.textColor =  UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
    

    
    

}

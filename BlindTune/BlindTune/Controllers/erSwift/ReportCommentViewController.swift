//
//  ReportCommentViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 29/06/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import Firebase

class ReportCommentViewController: UIViewController, UITextViewDelegate {


    @IBOutlet weak var textView: UITextView!
    let dataBaseRefReportPost = Database.database().reference(withPath: "ReportedPosts")
    var selectedDic = [String:Any]()
    var prevController = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView.text = "Comment here..."
        textView.textColor = UIColor.lightGray
        textView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.addDoneButtonOnKeyboard()
    }
    
    @IBAction func closeCommentView(_ sender: Any) {
        textView.resignFirstResponder()
        
       
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func buttonSendClicked(_ sender: Any) {
        textView.resignFirstResponder()
        
        if textView.text.isEmpty || textView.text == "Comment here..."  {
            textView.shake()
        }else{
            let someDate = Date()
            let timeInterval = someDate.timeIntervalSince1970
            let timeStamp = Double(timeInterval)
            
            var postId = String()
            var reportTo = String()
            
            
            
            if self.prevController == "home" {
                postId = selectedDic["postId"] as! String
                reportTo = selectedDic["userID"] as! String
            }else if self.prevController == "comment" {
                postId = selectedDic["postId"] as! String
                reportTo = selectedDic["replyBy"] as! String
            }else{
                postId = selectedDic["audioName"] as! String
                postId = postId.components(separatedBy: ".").first!
                reportTo = selectedDic["replyBy"] as! String
            }
        
            let reportPost = ["date":timeStamp, "postId": postId, "reason": textView.text!, "reportBy":AppDelegate.user._id,"reportTo": reportTo ] as [String : Any]
            self.dataBaseRefReportPost.child(selectedDic["postId"] as! String).setValue(reportPost)
            textView.text = "Comment here..."
            textView.textColor = UIColor.lightGray
            
            closeCommentView(UIButton())
            
            let alerController = UIAlertController(title: "Alert!", message: "your comment has been posted!!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alerController.addAction(alertAction)
            self.present(alerController, animated: true, completion: nil)
            
        }
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
    
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == self.textView {
            if textView.text.isEmpty {
                textView.text = "Comment here..."
                textView.textColor = UIColor.lightGray
            }
        }
        
    }

    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textView.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        textView.resignFirstResponder()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
     self.dismiss(animated: true, completion: nil)
    }
}

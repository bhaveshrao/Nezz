//
//  TextPostViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 14/03/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TextPostViewController: UIViewController, UITextViewDelegate  {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var activityIndicatorMain: NVActivityIndicatorView!
    
    @IBOutlet weak var textFieldContainerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        activityIndicatorMain.isHidden = true
        indicatorContainerView.isHidden = true
        
        
        textView.text = "What’s on your mind?"
        textView.textColor = UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)
        self.addDoneButtonOnKeyboard()
        // Do any additional setup after loading the view.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.resignFirstResponder()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0){
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What’s on your mind?"
            textView.textColor = UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .blackTranslucent
        
        doneToolbar.backgroundColor = UIColor(displayP3Red: 6/255.0, green: 5/255.0, blue: 26/255.0,
                                              alpha: 1)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(image: UIImage(named: "sendIcon"), style: .done, target: self, action
            : #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textView.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        textView.resignFirstResponder()
            
    }
    
    
      @IBAction func closeAction(_ sender: Any) {
          self.navigationController?.popViewController(animated: true)
      }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        let child = self.storyboard?.instantiateViewController(withIdentifier: "TitleChildViewController") as! TitleChildViewController
             self.addChild(child)
            
        self.textView.isUserInteractionEnabled = false
             child.view.frame = self.textFieldContainerView.frame
             self.view.addSubview(child.view)
             child.didMove(toParent: self)
        
    }
    func handleTextDataWith(title:String){
        

        let randomeInt = Int.random(in: 1...100000)
        let fileName = AppDelegate.username + String(format: "%d", randomeInt)
        let audioPost = AudioPost(userID: AppDelegate.username, audioTitle: title,
                                             audioName: self.textView.text!, audioURL: "",
                                             username: AppDelegate.username,
                                             timeCreated: (Date().timeIntervalSinceReferenceDate) ,
                                             timeDuration: "", postId : fileName ,
                                             commentCount : 0, postType: "text", text: self.textView.text!)
        self.sendTextDataToServer(parameters: audioPost.toAnyObject() as! [String:Any])
    }
    
    func sendTextDataToServer(parameters:[String:Any]){
           
           let headers = [
             "content-type": "application/json",
             "cache-control": "no-cache",
             "postman-token": "53a05c1c-f6a1-5b07-50c6-1f247c36c78f"
           ]
           
           var postData = Data()
           do {
              postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
           }catch {
               print(error)
           }

           let request = NSMutableURLRequest(url: NSURL(string: "http://104.248.118.154:6004/audioPost/create/")! as URL,
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
               let httpResponse = response as? HTTPURLResponse
               
               DispatchQueue.main.async {
                
                self.indicatorContainerView.isHidden = true
                self.activityIndicatorMain.stopAnimating()
                
                   let alerController = UIAlertController(title: "Congratulations!!", message: "Your message has been posted successfully!!", preferredStyle: .alert)
                     let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                         DispatchQueue.main.async {
                           self.navigationController?.viewControllers.forEach({ (ctrl) in
                              if ctrl.isKind(of: HomeFeedViewController.classForCoder()) {
                               self.navigationController?.popToViewController(ctrl, animated: true)
                               }
                           })
                       }
                     })
                     alerController.addAction(alertAction)
                     self.present(alerController, animated: true, completion: nil)
                   
               }
               
             }
           })
           dataTask.resume()
       }
         
    
    
    
    
}

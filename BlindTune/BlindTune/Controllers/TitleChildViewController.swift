//
//  TitleChildViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 14/03/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit

class TitleChildViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Add a title...",
                                                                  attributes:
            [NSAttributedString.Key.foregroundColor:
                UIColor(displayP3Red: 0.25, green: 0.34, blue: 0.73, alpha: 1.0)])
        titleTextField.textColor = UIColor.white
            self.titleTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendButtonAction(_ sender: Any) {
        willMove(toParent: nil)
        
        if (parent?.isKind(of: AudioPostViewController.classForCoder()))! {
            let controller = parent as! AudioPostViewController
            controller.handleAudioSendWithTitle(title: self.titleTextField.text!)
            view.removeFromSuperview()
            removeFromParent()
        }else{
            let controller = parent as! TextPostViewController
            controller.handleTextDataWith(title: self.titleTextField.text!);                    view.removeFromSuperview()
            removeFromParent()
        }
        
    }
    
    
}

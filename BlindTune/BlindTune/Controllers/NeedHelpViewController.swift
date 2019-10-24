//
//  NeedHelpViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 01/03/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit

class NeedHelpViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var resourceName = ""
    var pageTitle = ""
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = pageTitle
        // Do any additional setup after loading the view.
        let rtfPath = Bundle.main.url(forResource: resourceName, withExtension: "rtf")!

        do {
            let attributedStringWithRtf:NSAttributedString = try NSAttributedString(
                url: rtfPath,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
            self.textView.attributedText = attributedStringWithRtf
        }catch{
            print(error)
        }
      
  
        
    }
    
    //MARK:- User Action
    //MARK:-
    

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

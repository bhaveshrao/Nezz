//
//  AudioTextlandingPageViewController.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 11/03/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit

class AudioTextlandingPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func audioPostButtonAction(_ sender: Any) {
        let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "AudioPostViewController") as! AudioPostViewController
        ctrl.isControllerType = "createPost"
        ctrl.postDic = [:]
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @IBAction func textPostButtonAction(_ sender: Any) {
        
        let ctrl = self.storyboard?.instantiateViewController(withIdentifier: "TextPostViewController") as! TextPostViewController
               self.navigationController?.pushViewController(ctrl, animated: true)
    }
}

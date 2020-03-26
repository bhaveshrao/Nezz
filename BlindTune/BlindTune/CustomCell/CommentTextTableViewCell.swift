//
//  CommentTextTableViewCell.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 16/03/20.
//  Copyright © 2020 Bhavesh Rao. All rights reserved.
//

import UIKit

class CommentTextTableViewCell: UITableViewCell {

 
     @IBOutlet weak var titleLabel: UILabel!
     @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sepreatorLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet weak var cellTypeIndicatorImage: UIImageView!
    override func awakeFromNib() {
        usernameLabel.textColor = UIColor(red: 0.632, green: 0.803, blue: 1, alpha: 0.6)
        commentLabel.textColor = UIColor(red: 0.632, green: 0.803, blue: 1, alpha: 0.6)
        messageLabel.textColor = UIColor(red: 0.892, green: 0.942, blue: 1, alpha: 0.8)
        cellTypeIndicatorImage.image = UIImage(named: "textIcon")
        self.sepreatorLabel.isHidden = false
        self.messageLabel.isHidden = false
    }
}

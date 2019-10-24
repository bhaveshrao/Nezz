//
//  TextCommentTableViewCell.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 29/06/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit

class TextCommentTableViewCell: UITableViewCell {
    @IBOutlet var labelAudioTitle: UILabel!
    @IBOutlet var labelTextReply: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var userCountButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

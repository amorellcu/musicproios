//
//  MessageCell.swift
//  musicprof
//
//  Created by John Doe on 7/10/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override var textLabel: UILabel? {
        return messageLabel
    }
    
    override var imageView: UIImageView? {
        return avatarImageView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

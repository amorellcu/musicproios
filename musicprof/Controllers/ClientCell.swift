//
//  ClientCell.swift
//  musicprof
//
//  Created by John Doe on 7/14/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ClientCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!    
    @IBOutlet weak var messageCountLabel: UILabel?
    
    override var textLabel: UILabel? {
        return nameLabel
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

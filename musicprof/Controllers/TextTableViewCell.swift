//
//  TextTableViewCell.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 26/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    override var textLabel: UILabel? {
        return self.contentLabel
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

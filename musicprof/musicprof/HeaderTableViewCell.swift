//
//  HeaderTableViewCell.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 02/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var togglebutton: UIButton!    

    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

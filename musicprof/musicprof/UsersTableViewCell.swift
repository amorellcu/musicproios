//
//  UsersTableViewCell.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 06/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit



class UsersTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var iconcell: UIImageView!
    
    @IBOutlet weak var cellswitch: UISwitch!
    @IBOutlet weak var labelcell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
}

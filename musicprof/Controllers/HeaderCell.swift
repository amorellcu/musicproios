//
//  Header1TableViewCell.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 26/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var imgizq: UIImageView!
    
    @IBOutlet weak var imgder: UIImageView!
    
    override var textLabel: UILabel? {
        return self.titleLabel
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

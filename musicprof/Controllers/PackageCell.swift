//
//  PackageCell.swift
//  musicprof
//
//  Created by John Doe on 6/29/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class PackageCell: UITableViewCell {
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!

    override var textLabel: UILabel? {
        return detailsLabel
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

//
//  ProfesorTableViewCell.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 24/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class ProfesorTableViewCell: UITableViewCell {

    @IBOutlet weak var profesorImage: UIImageView!
    @IBOutlet weak var profesorName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profesorImage.layer.cornerRadius = self.profesorImage.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

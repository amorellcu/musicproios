//
//  LocationCell.swift
//  musicprof
//
//  Created by John Doe on 7/16/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override var textLabel: UILabel? {
        return nameLabel
    }
    
    func updateColors() {
        self.backgroundColor = UIColor(red: 64/255, green: 65/255, blue: 66/255, alpha: 1)
        if isSelected {
            self.backView.backgroundColor = UIColor(red: 0, green: 1, blue: 180/255, alpha: 1)
        } else {
            self.backView.backgroundColor = UIColor(red: 1, green: 210/255, blue: 69/255, alpha: 1)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateColors()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.updateColors()
    }

}

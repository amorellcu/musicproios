//
//  InstrumentCollectionViewCell.swift
//  musicprof
//
//  Created by John Doe on 6/12/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class InstrumentCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    override var isSelected: Bool {
        didSet {
            self.updateColors()
        }
    }
    
    func updateColors() {
        if isSelected {
            self.iconImageView.tintColor = UIColor(red: 64/255, green: 65/255, blue: 66/255, alpha: 1)
            self.backView.backgroundColor = tintColor
        } else {
            self.iconImageView.tintColor = tintColor
            self.backView.backgroundColor = UIColor.clear
        }
    }
}

class TemplateFilter: ImageFilter {
    var filter: (Image) -> Image {
        return { image in image.withRenderingMode(.alwaysTemplate) }
    }
}

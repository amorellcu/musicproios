//
//  ToggleButton.swift
//  musicprof
//
//  Created by John Doe on 6/30/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

@IBDesignable class ToggleButton: UIView {
    let checkedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    let normalColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    
    @IBInspectable var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }
    
    @IBInspectable var isChecked = true {
        didSet {
            self.updateState()
        }
    }
    
    let nibName = "ToggleButton"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    func xibSetup() {
        backgroundColor = UIColor.clear
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        // Adding custom subview on top of our view
        addSubview(contentView)
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.updateState()
    }
    
    private func updateState() {
        if !isChecked {
            textLabel.textColor = normalColor
            leftImageView?.image = UIImage(named: "fleizqoff")
            rightImageView?.image = UIImage(named: "flederoff")
        } else {
            textLabel.textColor = checkedColor
            leftImageView?.image = UIImage(named: "flechaizq")
            rightImageView?.image = UIImage(named: "flechader")
        }
    }
}

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
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    
    @IBInspectable var text: String? {
        didSet {
            self.titleButton.setTitle(self.text, for: .normal)
        }
    }
    
    @IBInspectable var isChecked = false {
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
    
    open func updateState() {
        if !isChecked {
            titleButton.setTitleColor(normalColor, for: .normal)
            leftImageView?.image = UIImage(named: "fleizqoff")
            rightImageView?.image = UIImage(named: "flederoff")
        } else {
            titleButton.setTitleColor(checkedColor, for: .normal)
            leftImageView?.image = UIImage(named: "flechaizq")
            rightImageView?.image = UIImage(named: "flechader")
        }        
    }
    
    @IBAction open func onClicked(_ sender: Any) {
        self.isChecked = !self.isChecked        
    }
}

class SectionHeader: ToggleButton {
    @IBOutlet weak var container: UIStackView?
    @IBOutlet weak var contentConstraint: NSLayoutConstraint?
    
    override func updateState() {
        super.updateState()
        guard let constraint = self.contentConstraint else { return }
        constraint.priority = self.isChecked ? .defaultLow : .defaultHigh
    }
    
    override func onClicked(_ sender: Any) {
        super.onClicked(sender)
        
        guard let container = self.container ?? self.superview as? UIStackView else { return }
        for view in container.subviews {
            guard let section = view as? SectionHeader, section !== self else { continue }
            section.isChecked = false
        }
        
        UIView.animate(withDuration: 1) {
            (container.superview ?? container).layoutIfNeeded()
        }
    }
}

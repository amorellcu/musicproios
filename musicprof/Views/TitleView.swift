//
//  TitleView.swift
//  musicprof
//
//  Created by John Doe on 7/16/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

@IBDesignable
class TitleView: UIView {
    
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var creditsView: UIView!
    @IBOutlet var contentView: UIView!
    
    @IBInspectable var credits: String = "" {
        didSet {
            self.creditsLabel.text = self.credits
        }
    }
    
    @IBInspectable var showCredits: Bool = true {
        didSet {
            self.creditsView.isHidden = !self.showCredits
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
    
    let nibName = "TitleView"
    
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
    }
}



//
//  TransparentButton.swift
//  musicprof
//
//  Created by John Doe on 6/27/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

@IBDesignable class TransparentButton: UIButton {
    @IBInspectable var disabledOpacity: CGFloat = 0.2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = self.isEnabled ? 1 : self.disabledOpacity
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.alpha = self.isEnabled ? 1 : self.disabledOpacity
    }
    
    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1 : self.disabledOpacity
        }
    }
}

//
//  UIToolbar.swift
//  musicprof
//
//  Created by John Doe on 7/18/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

extension UIToolbar {
    func setTransparent() {
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
    }
}

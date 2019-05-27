//
//  UIViewController.swift
//  musicprof
//
//  Created by John Doe on 5/26/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

extension UIViewController {
    var api: ApiStudent {
        return ApiStudent.sharedInstance
    }
}

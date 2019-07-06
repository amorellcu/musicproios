//
//  ProfileSection.swift
//  musicprof
//
//  Created by John Doe on 7/6/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

protocol ProfileSection: class {
    var updater: ProfileUpdateViewController? { get set }
    
    func refresh()
}

extension ProfileSection {
    func refresh() { }
}

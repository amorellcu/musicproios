//
//  MessageHandler.swift
//  musicprof
//
//  Created by Jon Doe on 9/19/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

protocol MessageHandler: class {
    func handleMessage(_ message: Message) -> Bool
}

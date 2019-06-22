//
//  User.swift
//  musicprof
//
//  Created by John Doe on 6/22/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

class Client: NSObject, Decodable, NSCoding {
    let id: Int
    let name: String
    let email: String?
    let avatarUrl: URL?
    let facebookId: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let user = try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        self.id = try user.decode(Int.self, forKey: .id)
        self.name = try user.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.email = try user.decodeIfPresent(String.self, forKey: .email)
        let avatar = try user.decodeIfPresent(String.self, forKey: .avatar)
        self.avatarUrl = avatar == nil ? nil : URL(string: avatar!)
        self.facebookId = try user.decodeIfPresent(String.self, forKey: .facebookId)
    }
    
    required init?(coder: NSCoder) {
        self.id = coder.decodeInteger(forKey: UserKeys.id.rawValue)
        self.name = coder.decodeObject(forKey: UserKeys.name.rawValue) as? String ?? ""
        self.email = coder.decodeObject(forKey: UserKeys.email.rawValue) as? String
        let avatar = coder.decodeObject(forKey: UserKeys.avatar.rawValue) as? String
        self.avatarUrl = avatar == nil ? nil : URL(string: avatar!)
        self.facebookId = coder.decodeObject(forKey: UserKeys.facebookId.rawValue) as? String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: UserKeys.id.rawValue)
        coder.encode(self.name, forKey: UserKeys.name.rawValue)
        coder.encode(self.email, forKey: UserKeys.avatar.rawValue)
        coder.encode(self.avatarUrl?.absoluteURL, forKey: UserKeys.avatar.rawValue)
        coder.encode(self.facebookId, forKey: UserKeys.facebookId.rawValue)
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case user
    }
    
    fileprivate enum UserKeys: String, CodingKey {
        case id
        case name
        case email
        case avatar = "photo"
        case facebookId = "facebook_id"
    }
}

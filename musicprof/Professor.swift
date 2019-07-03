//
//  Professor.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

class Professor: Decodable {
    var id: Int
    var name: String
    var phone: String?
    var email: String?
    var address: String?
    var price: Float? = nil
    var avatarUrl: URL?
    var facebookId: String?
    
    var personalReview: String?
    var workExperience: String?
    var academicTraining: String?
    
    var classes: [Class]?
    var locations: [Location]?
    var instruments: [Instrument]?
    
    static let standard = Professor(id: 0, name: "Allan Buenfill Mejías")
    
    private init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.personalReview = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        self.workExperience = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        self.academicTraining = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let user = container.contains(.user) ? try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user) : nil
        self.id = try user?.decode(Int.self, forKey: .id) ?? container.decode(Int.self, forKey: .id)
        self.name = try (container.decodeIfPresent(String.self, forKey: .name)
            ?? user?.decodeIfPresent(String.self, forKey: .name))
            ?? ""
        self.email = try user?.decodeIfPresent(String.self, forKey: .email)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        let avatar = try user?.decodeIfPresent(String.self, forKey: .avatar)
        self.avatarUrl = avatar == nil ? nil : URL(string: avatar!)
        self.facebookId = try user?.decodeIfPresent(String.self, forKey: .facebookId)
        
        self.personalReview = try container.decodeIfPresent(String.self, forKey: .personalReview)
        self.workExperience = try container.decodeIfPresent(String.self, forKey: .workExperience)
        self.academicTraining = try container.decodeIfPresent(String.self, forKey: .academicTraining)
        
        self.instruments = try container.decodeIfPresent([Instrument].self, forKey: .instruments)
        self.locations = try container.decodeIfPresent([Location].self, forKey: .locations)
        self.classes = try container.decodeIfPresent([Class].self, forKey: .classes)
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case user
        case phone
        case name
        case address
        case personalReview = "resenna_personal"
        case workExperience = "experiencia_laboral"
        case academicTraining = "formacion_academica"
        case locations = "colonias"
        case instruments
        case classes = "classes"
    }
    
    fileprivate enum UserKeys: String, CodingKey {
        case id
        case name
        case email
        case avatar = "photo"
        case facebookId = "facebook_id"
    }
}

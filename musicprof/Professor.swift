//
//  Professor.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation
import Alamofire

class Professor: NSObject, Decodable, NSCoding, User {
    var id: Int
    var name: String
    var phone: String?
    var email: String?
    var address: String?
    var price: Float? = nil
    var levelId: Int?
    var municipalityId: Int?
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
    
    override init() {
        self.id = -1
        self.name = "Profesor"
        super.init()
    }
    
    init(copy other: Professor) {
        self.id = other.id
        self.name = other.name
        self.email = other.email
        self.phone = other.phone
        self.address = other.address
        self.avatarUrl = other.avatarUrl
        self.facebookId = other.facebookId
        self.levelId = other.levelId
        self.municipalityId = other.municipalityId
        self.personalReview = other.personalReview
        self.workExperience = other.workExperience
        self.academicTraining = other.academicTraining
        self.classes = other.classes
        self.locations = other.locations
        self.instruments = other.instruments
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
        self.levelId = try container.decodeIfPresent(Int.self, forKey: .levelId)
        self.municipalityId = try container.decodeIfPresent(Int.self, forKey: .municipalityId)
        
        self.personalReview = try container.decodeIfPresent(String.self, forKey: .personalReview)
        self.workExperience = try container.decodeIfPresent(String.self, forKey: .workExperience)
        self.academicTraining = try container.decodeIfPresent(String.self, forKey: .academicTraining)
        
        self.instruments = try container.decodeIfPresent([Instrument].self, forKey: .instruments)
        self.locations = try container.decodeIfPresent([Location].self, forKey: .locations)
        self.classes = try container.decodeIfPresent([Class].self, forKey: .classes)
    }
    
    required init?(coder: NSCoder) {
        self.id = coder.decodeInteger(forKey: UserKeys.id.rawValue)
        self.name = coder.decodeObject(forKey: UserKeys.name.rawValue) as? String ?? ""
        self.email = coder.decodeObject(forKey: UserKeys.email.rawValue) as? String
        self.phone = coder.decodeObject(forKey: CodingKeys.phone.rawValue) as? String
        self.address = coder.decodeObject(forKey: CodingKeys.address.rawValue) as? String
        let avatar = coder.decodeObject(forKey: UserKeys.avatar.rawValue) as? String
        self.avatarUrl = avatar == nil ? nil : URL(string: avatar!)
        self.facebookId = coder.decodeObject(forKey: UserKeys.facebookId.rawValue) as? String
        self.instruments = nil
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: UserKeys.id.rawValue)
        coder.encode(self.name, forKey: UserKeys.name.rawValue)
        coder.encode(self.email, forKey: UserKeys.avatar.rawValue)
        coder.encode(self.phone, forKey: CodingKeys.phone.rawValue)
        coder.encode(self.address, forKey: CodingKeys.address.rawValue)
        coder.encode(self.avatarUrl?.absoluteURL, forKey: UserKeys.avatar.rawValue)
        coder.encode(self.facebookId, forKey: UserKeys.facebookId.rawValue)
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case user
        case phone
        case name
        case address
        case municipalityId = "id_municipio"
        case levelId = "level_id"
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

extension Professor {
    override func isEqual(_ object: Any?) -> Bool {
        let lhs = self
        guard let rhs = object as? Professor else { return false }
        return lhs.id == rhs.id &&
            lhs.name == rhs.name && lhs.email == rhs.email &&
            lhs.phone == rhs.phone &&
            lhs.address == rhs.address && 
            lhs.facebookId == rhs.facebookId && lhs.avatarUrl == rhs.avatarUrl &&
            Set(lhs.instruments ?? []) == Set(rhs.instruments ?? [])
    }
}

extension Professor: MultiformEncodable {
    func encode(to form: MultipartFormData) {
        form.encode(self.name, withName: CodingKeys.name.rawValue)
        form.encodeIfPresent(self.email, withName: UserKeys.email.rawValue)
        form.encodeIfPresent(self.phone, withName: CodingKeys.phone.rawValue)
        form.encodeIfPresent(self.address, withName: CodingKeys.address.rawValue)
        form.encodeIfPresent(self.levelId, withName: CodingKeys.levelId.rawValue)
        form.encodeIfPresent(self.municipalityId, withName: CodingKeys.municipalityId.rawValue)
        form.encodeValues(self.locations?.map({$0.id}), withName: "coloniaId")
        form.encodeValues(self.instruments?.map({$0.id}), withName: CodingKeys.instruments.rawValue)
        form.encodeIfPresent(self.facebookId, withName: "facebookID")
        form.encode(1, withName: "paymentTypeId")
        if let avatarUrl = self.avatarUrl, avatarUrl.isFileURL {
            form.append(avatarUrl, withName: UserKeys.avatar.rawValue)
        }
    }
}

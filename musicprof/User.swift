//
//  User.swift
//  musicprof
//
//  Created by John Doe on 7/8/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import Alamofire

protocol User: class {
    var id: Int { get }
    var name: String { get set }
    var email: String? { get set }
    var phone: String? { get set }
    var address: String? { get set }
    var avatarUrl: URL? { get set }
    var facebookId: String? { get set }
    var instruments: [Instrument]? { get set }
}

extension User {
    func loadFromFB(overwrite: Bool = false, completion: @escaping (Error?) -> Void) {
        guard FBSDKAccessToken.current() != nil else {
            return completion(AppError.invalidOperation)
        }
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start { (connection, result, error) -> Void in
            DispatchQueue.main.async {
                if let error = error {
                    completion(error)
                } else if let dict = result as? [String : Any] {
                    let picture = dict["picture"] as? [String: Any]
                    var data = picture?["data"] as? [String : Any]
                    let imageUrlString = data?["url"] as? String
                    
                    if overwrite {
                        self.avatarUrl = (imageUrlString == nil ? nil : URL(string: imageUrlString!)) ?? self.avatarUrl
                        self.name = dict["name"] as? String ?? self.name
                        self.email = dict["email"] as? String ?? self.email
                        self.facebookId = (dict["id"] as? String) ?? self.facebookId
                    } else {
                        self.avatarUrl = self.avatarUrl ?? (imageUrlString == nil ? nil : URL(string: imageUrlString!))
                        self.name = self.name.isEmpty ? (dict["name"] as? String ?? "") : self.name
                        self.email = self.email ?? dict["email"] as? String
                        self.facebookId = self.facebookId ?? (dict["id"] as? String)
                    }
                    
                    completion(nil)
                } else {
                    completion(AppError.unsupportedData)
                }
            }
        }
    }
}

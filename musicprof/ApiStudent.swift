//
//  ApiStudent.swift
//  musicprof
//
//  Created by Alexis Morell on 23/04/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import FacebookCore
import FacebookLogin

let configuration = Configuration()

public class ApiStudent {
    var headers:[String : String]?
    var params:[String : Any]?
    
    static let sharedInstance = ApiStudent()
    
    var nameclient = ""
    var urlphoto = ""
    var user:NSDictionary = [:]
    
    static fileprivate let queue = DispatchQueue(label: "requests.queue", qos: .utility)
    static fileprivate let mainQueue = DispatchQueue.main
    
    public func setHeaders(aheader:[String:String]){
        self.headers = aheader
    }
    
    public func setParams(aparams:[String : Any]){
       self.params = aparams
    }
    
    public func getParams()->[String : Any]{
        return self.params!
    }
    public func getHeaders()->[String:String]{
        return self.headers!
    }
    
    fileprivate class func make(request: DataRequest, closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        request.responseJSON(queue: ApiStudent.queue) { response in
            switch response.result {
            case .failure(let error):
                ApiStudent.mainQueue.async {
                    closure(nil, error)
                }
                
            case .success(let data):
                ApiStudent.mainQueue.async {
                    closure((data as? [String: Any]) ?? [:], nil)
                }
            }
        }
    }
    
    public func login(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let request1 = request("\(configuration.urlapi)/loginClient", method: .post, parameters: self.params, headers: self.headers!)
        ApiStudent.make(request: request1) { json, error in
            closure(json, error)
        }
    }
    
    public func logout(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let req = request("\(configuration.urlapi)/logout", method: .get, headers: self.headers!)
        ApiStudent.make(request: req) { json, error in
            let fbLoginManager = LoginManager()
            fbLoginManager.logOut()
            AccessToken.current = nil
            UserProfile.current = nil
            closure(json, error)
        }
    }
    
    func getUserData(JSON: NSDictionary)->[String:String]{
        var userdata = [String:String]()
        if(String(describing: JSON["result"]!) == "Error"){
            let alertView = SCLAlertView()
            alertView.showError("Error Autenticación", subTitle: String(describing: JSON["message"]!)) // Error
        } else if(String(describing: JSON["result"]!) == "OK"){
            let data = JSON["data"] as? [String: Any]
            let cliente = data!["client"] as? [String: Any]
            let subaccounts = cliente!["subaccounts"] as! NSArray
            let user = cliente!["user"] as? [String: Any]
            userdata["urlphoto"] = user!["photo"] as? String
            if(subaccounts.count > 0){
                let subcuenta = subaccounts[0] as? [String: Any]
                userdata["name"] = subcuenta!["name"] as? String
                
            }
            else {
                let user = cliente!["user"] as! [String: Any]
                userdata["name"] = user["name"] as? String
            }
        }
        return userdata
        
    }
    
    public func getAllInstruments(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let request1 = request("\(configuration.urlapi)/getInstruments", method: .get)
        ApiStudent.make(request: request1) { json, error in
            closure(json, error)
        }
    }
    
    public func registrarCliente(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let request1 = request("\(configuration.urlapi)/registerClient", method: .post, parameters: self.params,headers:headers!)
        ApiStudent.make(request: request1) { json, error in
            closure(json, error)
            print(error.debugDescription)
        }
    }
    
    public func loginFacebookToken(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let request1 = request("\(configuration.urlapi)/loginWithFacebook?accessToken=\(String(describing: self.params!["token"]!))", method: .get)
        ApiStudent.make(request: request1) { json, error in
            closure(json, error)
        }
    }
    
    public func updateAddress(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let request1 = request("\(configuration.urlapi)/updateAddress", method: .post, parameters: self.params,headers:headers!)
        ApiStudent.make(request: request1) { json, error in
            closure(json, error)
            print(error.debugDescription)
        }
    }
    
    public func getClient(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let request1 = request("\(configuration.urlapi)/getClientData?clientId=\(self.params!["id"]!)", method: .get, parameters: self.params,headers:headers!)
        ApiStudent.make(request: request1) { json, error in
            closure(json, error)
            print(error.debugDescription)
        }
    }
    
    public func getScheduleProfesor(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let request1 = request("\(configuration.urlapi)/getAvailableProfesorsOnDate1?coloniaId=\(self.params!["coloniaId"]!)&instrumentId=\(self.params!["instrumentId"]!)&classDate=\(self.params!["classDate"]!)", method: .get,headers:headers!)
        ApiStudent.make(request: request1) { json, error in
            closure(json, error)
            print(error.debugDescription)
        }
    }
    
    public func getColony(closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let url = "\(configuration.urlapi)/getSublocality?address=\(self.params!["address"]!)"
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let request1 = request(encodedUrl!, method: .get)
        ApiStudent.make(request: request1) { json, error in
            closure(json, error)
            print(error.debugDescription)
        }
    }
    
}

//
//  ApiStudent.swift
//  musicprof
//
//  Created by Alexis Morell on 23/04/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import Alamofire

let configuration = Configuration()

public class ApiStudent {
    var headers:[String : String]?
    var params:[String : Any]?
    
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

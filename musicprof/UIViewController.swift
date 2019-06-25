//
//  UIViewController.swift
//  musicprof
//
//  Created by John Doe on 5/26/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView

extension UIViewController {
    var service: ApiManager {
        return ApiManager.shared
    }
    
    func notify(error: Error, completion: (() -> Void)? = nil) {
        var completion = completion
        let title = "Error"
        var msg: String
        switch error{
        case let serviceError as ApiError:
            msg = serviceError.description
        case let afError as AFError where afError.responseCode == 401:
            msg = "Your credentials expired. Please, login again."
            //completion = { self.signOut(completion: completion) }
            fatalError()
        default:
            msg = error.localizedDescription
        }
        let ok = "Aceptar"
        print("ERROR: \(msg)")
        
        let controller = SCLAlertView()
        let responder = controller.showError(title, subTitle: msg)
        if let completion = completion {
            responder.setDismissBlock(completion)
        }
    }
    
    func notify(message: String, title: String, button: String = "Aceptar", completion: (() -> Void)? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: button, style: .default, handler: {action in completion?() }))
        self.present(controller, animated: true)
    }
    
    func ask(question: String, title: String, yesButton: String = "Aceptar", noButton: String = "Cancelar", completion handler: ((Bool) -> Void)? = nil) {
        let controller = UIAlertController(title: title, message: question, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: noButton, style: .cancel, handler: {_ in handler?(false)}))
        controller.addAction(UIAlertAction(title: yesButton, style: .default, handler: {_ in handler?(true)}))
        self.present(controller, animated: true)
    }
    
    func handleResult<T>(_ result: ApiResult<T>, onError: ((Error) -> Void)? = nil, onSuccess: ((T) throws -> Void)? = nil) {
        switch result {
        case let .success(data):
            guard let onSuccess = onSuccess else { break }
            do {
                try onSuccess(data)
            } catch {
                self.notify(error: error)
                guard let onError = onError else { break }
                onError(error)
            }
        case let .failure(error):
            self.notify(error: error)
            guard let onError = onError else { break }
            onError(error)
        }
    }
    
    func handleResult<T>(_ result: ApiResult<T>, onError: ((Error) -> Void)? = nil, onSuccess: @escaping (() throws -> Void)) {
        self.handleResult(result, onError: onError) { (_) in
            try onSuccess()
        }
    }
}

var vSpinner : UIView?

extension UIViewController {
    var api: ApiStudent {
        return ApiStudent.sharedInstance
    }
    
    func onLogoutAction(activityIndicator ai: UIActivityIndicatorView, closeIcon icon: UIImageView) {
        ai.startAnimating()
        icon.isHidden = true
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        self.api.setHeaders(aheader: headers)
        self.api.logout(){ json, err in
            ai.stopAnimating()
            icon.isHidden = false
            
            if(err != nil) {
                self.performSegue(withIdentifier: "unwindToLogin", sender: self)
            } else {
                
            }
        }
    }
    
    //Spinner dialog
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
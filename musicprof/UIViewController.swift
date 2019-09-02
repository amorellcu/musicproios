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
    
    var menu: MenuViewController? {
        return self.tabBarController as? MenuViewController
    }
    
    func notify(error: Error, completion: (() -> Void)? = nil) {
        var completion = completion
        let title = "Error"
        var msg: String
        switch error{
        case let serviceError as ApiError:
            msg = serviceError.description
        case let appError as AppError:
            msg = appError.description
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
        let responder = controller.showError(title, subTitle: msg, closeButtonTitle: "Aceptar")
        if let completion = completion {
            responder.setDismissBlock(completion)
        }
    }
    
    func notify(message: String, title: String, button: String = "Aceptar", completion: (() -> Void)? = nil) {
        let controller = SCLAlertView()
        controller.showInfo(title, subTitle: message, closeButtonTitle: button).setDismissBlock {
            completion?()
        }
    }
    
    func ask(question: String, title: String, yesButton: String = "Aceptar", noButton: String = "Cancelar", completion handler: ((Bool) -> Void)? = nil) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton(yesButton, action: {handler?(true)})
        alert.addButton(noButton, action: {handler?(false)})
        alert.showWarning(title, subTitle: question, colorStyle: SCLAlertViewStyle.question.defaultColorInt)
    }
    
    func handleResult<T>(_ result: ApiResult<[T]>, onError: ((Error) -> Void)? = nil, onSuccess: (([T]) throws -> Void)? = nil) {
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
            if let apiError = error as? ApiError, apiError.result == "ZERO_RESULTS" {
                guard let onSuccess = onSuccess else { break }
                do {
                    try onSuccess([])
                } catch {
                    self.notify(error: error)
                    guard let onError = onError else { break }
                    onError(error)
                }
            } else {
                self.notify(error: error)
                guard let onError = onError else { break }
                onError(error)
            }
        }
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

extension UIViewController {
    
    func onLogoutAction(activityIndicator ai: UIActivityIndicatorView, closeIcon icon: UIImageView) {
        ai.startAnimating()
        icon.isHidden = true
        
        self.service.signOut()
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    func checkTermsAndConditions(rejectHandler: (()-> Void)? = nil, acceptHandler: (()-> Void)? = nil) {
        let alert = self.showSpinner()
        self.service.getTermsAndConditions { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) { terms in
                self?.ask(question: terms, title: "Términos y Condiciones", yesButton: "Aceptar", noButton: "Rechazar", completion: { (accepted) in
                    let alert = self?.showSpinner()
                    self?.service.replyTermsAndConditions(accepted: accepted, handler: { (result) in
                        self?.handleResult(result) {
                            if accepted {
                                acceptHandler?()
                            } else {
                                rejectHandler?()
                            }
                        }
                    })
                    
                })
            }
        }
    }
    
    //Spinner dialog
    func showSpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        spinnerView.addSubview(ai)
        onView.addSubview(spinnerView)

        
        return spinnerView
    }
    
    func showSpinner(withMessage message: String? = nil) -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false, shouldAutoDismiss: false)
        let alert = SCLAlertView(appearance: appearance)
        alert.showWait("Espere, por favor", subTitle: message ?? "", colorStyle: SCLAlertViewStyle.notice.defaultColorInt)
        return alert
    }
}

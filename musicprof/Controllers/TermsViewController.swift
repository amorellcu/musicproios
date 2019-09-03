//
//  TermsViewController.swift
//  musicprof
//
//  Created by Jon Doe on 9/3/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {
    @IBOutlet weak var acceptButton: UIBarButtonItem!
    @IBOutlet weak var rejectButton: UIBarButtonItem!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var accepted: Bool?
    var acceptHandler: (() -> Void)?
    var rejectHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let alert = self.showSpinner(withMessage: "Cargando contenido...")
        self.service.getTermsAndConditions { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) { text in
                self?.loadText(text)
            }
        }
    }
    
    private func loadText(_ htmlText: String) {
        let encodedData = htmlText.data(using: String.Encoding.utf8)!
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
            contentLabel.attributedText = attributedString
        } catch let error as NSError {
            self.notify(error: error)
        } catch {
            print("error")
            return
        }
    }
    
    @IBAction func onAcceptTapped(_ sender: Any) {
        accepted = true;
        let alert = self.showSpinner(withMessage: "Enviando respuesta...")
        self.service.replyTermsAndConditions(accepted: true) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                guard let strongSelf = self else { return }
                strongSelf.performSegue(withIdentifier: "accepted", sender: sender)
                guard let handler = strongSelf.acceptHandler else { return }
                DispatchQueue.main.async(execute: handler)
            }            
        }
    }
    
    @IBAction func onRejectTapped(_ sender: Any) {
        accepted = false;
        let alert = self.showSpinner(withMessage: "Enviando respuesta...")
        self.service.replyTermsAndConditions(accepted: false) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                guard let strongSelf = self else { return }
                strongSelf.performSegue(withIdentifier: "rejected", sender: sender)
                guard let handler = strongSelf.rejectHandler else { return }
                DispatchQueue.main.async(execute: handler)
            }
        }
    }
}

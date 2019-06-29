//
//  ContainerViewController.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class ContainerViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var closeIconImageView: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var fullDisplayConstraint: NSLayoutConstraint!
    @IBOutlet weak var pictureDisplayConstraint: NSLayoutConstraint!
    
    private(set) var displayMode: DisplayMode = .full

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setTransparentBar()
        self.profileNameLabel.text = self.service.user?.name
        let placeholderAvatar = UIImage(named:"userdefault")
        if let avatarUrl = self.service.user?.avatarUrl {
            let filter = ScaledToSizeCircleFilter(size: self.avatarImageView.frame.size)
            self.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: UIImage(named:"userdefault"), filter: filter)
        } else {
            self.avatarImageView.image = placeholderAvatar?.af_imageAspectScaled(toFit: self.avatarImageView.frame.size).af_imageRoundedIntoCircle()
        }
        self.avatarImageView.clipsToBounds = true
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        //let userInfo = notification.userInfo!
        
        //let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            //self.setDisplayMode(.full, animated: true)
        } else {
            self.setDisplayMode(.collapsed, animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? NestedController ??
            (segue.destination as? UINavigationController)?.viewControllers.first as? NestedController else {
            return
        }
        controller.container = self
    }
    
    @IBAction func onCloseTapped(_ sender: UIButton) {
        self.onLogoutAction(activityIndicator: activityIndicator, closeIcon: closeIconImageView)
    }
    
    private func updateVisibility() {
        switch self.displayMode {
        case .collapsed:
            self.avatarImageView.isHidden = true
            self.closeIconImageView.isHidden = true
            self.signOutButton.isHidden = true
            self.profileNameLabel.isHidden = true
        case .picture:
            self.avatarImageView.isHidden = false
            self.closeIconImageView.isHidden = false
            self.signOutButton.isHidden = false
            self.profileNameLabel.isHidden = true
        case .full:
            self.avatarImageView.isHidden = false
            self.closeIconImageView.isHidden = false
            self.signOutButton.isHidden = false
            self.profileNameLabel.isHidden = false
        }
    }
    
    private func updateConstraints() {
        switch self.displayMode {
        case .collapsed:
            self.fullDisplayConstraint.priority = .defaultLow
            self.pictureDisplayConstraint.priority = .defaultLow
        case .picture:
            self.fullDisplayConstraint.priority = .defaultLow
            self.pictureDisplayConstraint.priority = .defaultHigh
        case .full:
            self.fullDisplayConstraint.priority = UILayoutPriority(999)
            self.pictureDisplayConstraint.priority = .defaultHigh
        }
    }
    
    func setDisplayMode(_ displayMode: DisplayMode, animated: Bool) {
        guard self.displayMode != displayMode else { return }
        let isGrowing = displayMode.rawValue > self.displayMode.rawValue
        self.displayMode = displayMode
        if !isGrowing || !animated {
            self.updateVisibility()
        }
        self.updateConstraints()
        guard animated else { return }
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: {_ in
            if isGrowing {
                self.updateVisibility()
            }
        })
    }
    
    enum DisplayMode: Int {
        case collapsed = 0
        case picture = 1
        case full = 2
    }
}

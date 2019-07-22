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
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var avatarToolbar: UIToolbar!
    
    var customTitleView: TitleView?
    
    @IBOutlet weak var fullDisplayConstraint: NSLayoutConstraint!
    @IBOutlet weak var pictureDisplayConstraint: NSLayoutConstraint!
    
    private(set) var displayMode: DisplayMode = .full
    private(set) var preferredDisplayMode: DisplayMode = .full
    private var isKeyboardVisible: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setTransparentBar()
        self.avatarImageView.clipsToBounds = true
        
        if let _ = self.service.currentClient {
            self.customTitleView = TitleView()
            self.navigationItem.titleView = self.customTitleView
            self.customTitleView?.sizeToFit()
        }
        
        self.avatarToolbar.setTransparent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.onKeyboardHidden(animated: animated)
        
        refresh()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func refresh() {
        self.profileNameLabel.text = self.service.user?.name
        if let client = self.service.user as? Client {
            if let credits = client.credits {
                self.customTitleView?.credits = credits.description
            } else {
                self.customTitleView?.credits = "?"
            }
            self.service.getClientCredits { [weak self] (result) in
                self?.handleResult(result) {
                    client.credits = $0
                    self?.customTitleView?.credits = $0.description
                }
            }
        }
        self.setAvatar(self.service.user?.avatarUrl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setAvatar(_ url: URL?) {
        let placeholderAvatar = UIImage(named:"userdefault")?.af_imageAspectScaled(toFit: self.avatarImageView.frame.size).af_imageRoundedIntoCircle()
        if let avatarUrl = url {
            let filter = ScaledToSizeCircleFilter(size: self.avatarImageView.frame.size)
            self.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: placeholderAvatar, filter: filter)
        } else {
            self.avatarImageView.image = placeholderAvatar
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.onKeyboardHidden(animated: true)
        } else {
            self.isKeyboardVisible = true
            self.internalSetDisplayMode(.collapsed, animated: true)
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
    
    @IBAction func onMenuTapped(_ sender: Any) {
        let title = "Opciones"
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Cerrar sesión", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }))
        controller.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            let bounds = self.view.bounds
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(controller, animated: true)
    }
    
    private func updateVisibility() {
        switch self.displayMode {
        case .collapsed:
            self.avatarImageView.isHidden = true
            self.profileNameLabel.isHidden = true
        case .picture:
            self.avatarImageView.isHidden = false
            self.profileNameLabel.isHidden = true
        case .full:
            self.avatarImageView.isHidden = false
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
        guard self.preferredDisplayMode != displayMode else { return }
        self.preferredDisplayMode = displayMode
        if !self.isKeyboardVisible {
            self.internalSetDisplayMode(displayMode, animated: animated)
        }
    }
    
    private func onKeyboardHidden(animated: Bool) {
        self.isKeyboardVisible = false
        self.internalSetDisplayMode(self.preferredDisplayMode, animated: animated)
    }
    
    private func internalSetDisplayMode(_ displayMode: DisplayMode, animated: Bool) {
        guard self.displayMode != displayMode else { return }
        let isGrowing = displayMode.rawValue > self.displayMode.rawValue
        self.displayMode = displayMode
        if !isGrowing || !animated {
            self.updateVisibility()
        }
        self.updateConstraints()
        guard animated else { return self.view.layoutIfNeeded() }
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

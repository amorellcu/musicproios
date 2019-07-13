//
//  ChatViewController.swift
//  musicprof
//
//  Created by John Doe on 7/10/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage
import SCLAlertView

class ChatViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var professorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var instrumentImageView: UIImageView!
    @IBOutlet weak var professorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fullProfileConstriant: NSLayoutConstraint!
    @IBOutlet weak var textInputConstraint: NSLayoutConstraint!
    
    var reservation: Reservation?
    var clientAvatar: URL?
    var professorAvatar: URL?
    var timer: Timer?
    
    var messages = [Message]() {
        didSet {
            self.tableView.reloadData()
            guard messages.count > 0, messages.count != oldValue.count else { return }
            //self.tableView.scrollToRow(at: IndexPath(item: messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setTransparentBar()
        self.titleLabel.text = ""
        if let date = self.reservation?.classes?.date {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es-ES")
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            self.titleLabel.text = "Clase \(formatter.string(from: date))"
        }
        self.professorLabel.text = self.reservation?.classes?.professor?.name
        self.clientAvatar = self.service.user?.avatarUrl
        self.setAvatar(clientAvatar, for: self.avatarImageView)
        self.professorAvatar = self.reservation?.classes?.professor?.avatarUrl
        self.setAvatar(professorAvatar, for: self.professorImageView)
        
        //self.setAvatar(reservation?.classes?.instrument?.iconUrl, for: self.instrumentImageView, defaultName: "no_instrument")
        let filter = TemplateFilter()
        if let iconURL = reservation?.classes?.instrument?.iconUrl {
            self.instrumentImageView.af_setImage(withURL: iconURL, filter: filter)
        } else {
            self.instrumentImageView.image = filter.filter(UIImage(named: "no_instrument")!)
        }
        
        self.cancelButton.isEnabled = self.reservation?.status == .normal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateMessages()
        
        let notificationCenter = NotificationCenter.default
        //notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (_) in
            self?.updateMessages()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func updateMessages() {
        guard let reservation = self.reservation else { return }
        self.service.getMessages(from: reservation) { (result) in
            self.handleResult(result) {
                self.messages = $0
            }
        }
    }
    
    private func setAvatar(_ url: URL?, for imageView: UIImageView, defaultName: String? = nil) {
        let placeholderAvatar = UIImage(named: defaultName ?? "userdefault")?.af_imageAspectScaled(toFit: imageView.frame.size).af_imageRoundedIntoCircle()
        if let avatarUrl = url {
            let filter = ScaledToSizeCircleFilter(size: imageView.frame.size)
            imageView.af_setImage(withURL: avatarUrl, placeholderImage: placeholderAvatar, filter: filter)
        } else {
            imageView.image = placeholderAvatar
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.textInputConstraint.constant = 0
            self.fullProfileConstriant.priority = .defaultHigh
            guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        } else {
            let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
            
            self.textInputConstraint.constant = -keyboardViewEndFrame.height
            self.fullProfileConstriant.priority = keyboardViewEndFrame.height == 0 ? .defaultHigh : .defaultLow
            guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func submitMessage(from textField: UITextField) {
        let text = textField.text ?? ""
        guard !text.isEmpty, let reservation = self.reservation else { return }
        textField.text = ""
        self.service.sendMessage(text, for: reservation) { (result) in
            self.handleResult(result) {
                self.messages.append($0)
            }
        }
    }

    @IBAction func onSubmitTapped(_ sender: Any) {
        self.submitMessage(from: self.messageTextField)
    }
    
    @IBAction func onDetailsTapped(_ sender: Any) {
        
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        guard let reservation = self.reservation else { return }
        self.ask(question: "¿Está seguro de que quiere cancelar la reservación?",
                 title: "Cancelando", yesButton: "Sí", noButton: "No") { (shouldCancel) in
                    guard shouldCancel else { return }
                    let alert = self.showSpinner(withMessage: "Cancelando la reservación...")
                    self.service.cancelReservation(reservation, handler: { [weak self] (result) in
                        alert.hideView()
                        self?.handleResult(result) {
                            self?.reservation?.status = .cancelled
                            self?.cancelButton.isEnabled = false
                        }
                    })
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.item]
        var identifier: String
        var avatarUrl: URL?
        switch message.source {
        case .local:
            identifier = "clientCell"
            avatarUrl = self.clientAvatar
        default:
            identifier = "professorCell"
            avatarUrl = self.professorAvatar
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        cell.textLabel?.text = message.text
        self.setAvatar(avatarUrl, for: cell.imageView!)
        return cell
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.submitMessage(from: textField)
        return true
    }
}

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
import PusherSwift

class ChatViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var professorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var instrumentImageView: UIImageView!
    @IBOutlet weak var professorLabel: UILabel?
    @IBOutlet weak var studentLabel: UILabel?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fullProfileConstriant: NSLayoutConstraint!
    @IBOutlet weak var textInputConstraint: NSLayoutConstraint!
    
    var pusher: Pusher?
    var reservation: Reservation?
    var client: Client?
    var student: Student? {
        guard let reservation = self.reservation, let client = self.client else { return nil }
        switch reservation.studentType {
        case .account:
            return client
        case .subaccount:
            return client.subaccounts?.first(where: {$0.id == reservation.subaccountId})
        case .guest:
            return Guest(userId: client.id,
                         name: self.reservation?.guestName ?? "", email: self.reservation?.guestEmail ?? "",
                         address: self.reservation?.address)
        }
    }
    var professor: Professor?
    var clientAvatar: URL? {
        return client?.avatarUrl
    }
    var professorAvatar: URL? {
        return professor?.avatarUrl
    }
    var timer: Timer?
    
    var messages = [Message]()
    var connection: ConnectionState = .disconnected
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setTransparentBar()
        self.client = self.client ?? self.service.currentClient ?? self.reservation?.client
        self.professor = self.professor ?? self.service.currentProfessor ?? self.reservation?.classes?.professor
        self.refresh()
        
        if let reservation = self.reservation {
            if self.client == nil, let clientId = reservation.clientId {
                self.service.getClient(withId: clientId) { [weak self] (result) in
                    self?.handleResult(result) {
                        self?.client = $0
                        self?.refresh()
                    }
                }
            }
            if self.professor == nil, let professorId = reservation.classes?.professorId {
                self.service.getProfessor(withId: professorId) { [weak self] (result) in
                    self?.handleResult(result) {
                        self?.professor = $0
                        self?.refresh()
                    }
                }
            }
        }
        
        self.initSocket()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.messageTextField, action: #selector(UIView.resignFirstResponder))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
    }
    
    func initSocket() {
        guard let reservation = self.reservation else { return }
        let options = PusherClientOptions(
            host: .cluster("us2")
        )
        
        let pusher = Pusher(
            key: "e27e7bc4b2d829641166",
            options: options
        )
        
        pusher.delegate = self
        
        // subscribe to channel and bind to event
        let channel = pusher.subscribe(channelName: "musicprof-chat-R\(reservation.id)")
        
        let _ = channel.bind(eventName: "event-chat-R\(reservation.id)", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let msg = Message(fromJSON: data) {
                    DispatchQueue.main.async {
                        guard self.isRemoteMessage(msg) else { return }
                        self.updateMessages(with: self.messages + [msg])
                    }
                }
            }
        })
        
        pusher.bind { (message: PusherEvent) in
            if message.eventName == "pusher:error" {
                print("[PUSHER] Error: \(message.data ?? "?")")
                guard let errorMessage = message.property(withKey: "message") as? String else { return }
                let code = message.property(withKey: "code") as? Int
                DispatchQueue.main.async { [weak self] in
                    self?.notify(message: errorMessage, title: "Error \(code?.description ?? "")")
                }
            }
        }
        
        self.pusher = pusher
    }
    
    func isRemoteMessage(_ msg: Message) -> Bool {
        switch msg.source {
        case .client where self.service.user is Client:
            return false
        case .professor where self.service.user is Professor:
            return false
        default:
            return true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateMessages()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true, block: { [weak self] (timer) in
            guard let strongSelf = self else {
                timer.invalidate()
                return
            }
            strongSelf.updateMessages()
        })
        
        pusher?.connect()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.messageHandler = self
        }
        
        /*Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            let message = Message(fromJSON: ["id": Int.random(in: 1...1000000), "class_id": self.reservation!.classId, "profesor_id": self.professor!.id, "message": "kk"])!
            self.updateMessages(with: self.messages + [message])
        }*/
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.messageHandler = nil
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        
        pusher?.disconnect()
        
        self.timer?.invalidate()
        self.timer = nil
        
//        UIApplication.shared.updateBadge {}
    }
    
    private func updateMessages(notify: Bool = false) {
        guard let reservation = self.reservation else { return }
        self.service.getMessages(from: reservation) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.updateMessages(with: data)
            case .failure(let error) where notify:
                self?.messageTextField.resignFirstResponder()
                self?.notify(error: error)
            default:
                break
            }
        }
    }
    
    func updateMessages(with newValue: [Message]) {
        let oldValue = self.messages
        self.messages = newValue
        self.tableView.reloadData()
        guard messages.count > 0, messages.count != oldValue.count else { return }
        self.tableView.scrollToRow(at: IndexPath(item: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    func refresh() {
        self.titleLabel.text = ""
        if let date = self.reservation?.classes?.date {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es-ES")
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            self.titleLabel.text = "Clase \(formatter.string(from: date))"
        }
        self.professorLabel?.text = self.professor?.name
        self.studentLabel?.text = self.student?.name
        self.setAvatar(clientAvatar, for: self.avatarImageView)
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
    
    private func setAvatar(_ url: URL?, for imageView: UIImageView, defaultName: String? = nil) {
        let placeholderAvatar = UIImage(named: defaultName ?? "userdefault")?.af_imageAspectScaled(toFit: imageView.frame.size).af_imageRoundedIntoCircle()
        if let avatarUrl = url {
            let filter = AspectScaledToFillSizeCircleFilter(size: imageView.frame.size)
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
            guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        } else {
            let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
            
            self.textInputConstraint.constant = -keyboardViewEndFrame.height
            self.fullProfileConstriant.priority = keyboardViewEndFrame.height == 0 ? .defaultHigh : .defaultLow
            guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return self.view.layoutIfNeeded()
            }
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
            self.handleResult(result, onError: {_ in textField.resignFirstResponder() }) {
                self.updateMessages(with: self.messages + [$0])
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
                            self?.performSegue(withIdentifier: "cancel", sender: sender)
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
        case .client:
            identifier = "clientCell"
            avatarUrl = self.clientAvatar
        case .professor:
            identifier = "professorCell"
            avatarUrl = self.professorAvatar
        default:
            return UITableViewCell()
        }
        
        if message.wasRead != true && self.isRemoteMessage(message) {
            self.service.notifyMessageRead(message) { result in
                switch result {
                case .success(let newValue):
                    self.messages[indexPath.item] = newValue
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                default:
                    break
                }
            }
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

extension ChatViewController: PusherDelegate {
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        self.connection = new
        if new == .connected {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func debugLog(message: String) {
        print(message)
    }
    
    func subscribedToChannel(name: String) {
        print("[PUSHER] Subscribed to channel \(name).")
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        print("[PUSHER] Could not subscribe to channel \(name): \(error?.localizedDescription ?? error?.description ?? "?").")
    }
}

extension ChatViewController: MessageHandler {
    func handleMessage(_ message: Message) -> Bool {
        guard message.reservationId == self.reservation?.id else { return false }
        switch message.source {
        case .client where self.service.user is Client || self.service.user?.id != message.professorId:
            return false
        case .professor where self.service.user is Professor || self.service.user?.id != message.clientId:
            return false
        default:
            break
        }
        if self.connection != .connected {
            self.updateMessages()
        }
        return true
    }
}

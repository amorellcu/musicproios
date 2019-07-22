//
//  InstrumentsViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 08/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage
import SCLAlertView
import ActionSheetPicker_3_0

class InstrumentsRegistrationViewController: InstrumentListViewController, ClientRegistrationController, InputController {
    
    var client: Client!
    var subaccount: Subaccount?
    var location: Location?
    var locations: [Location]?
    
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var studentNameTextField: UITextField?
    @IBOutlet weak var addressTextField: UITextField?
    @IBOutlet weak var locationButton: UIButton?
    @IBOutlet weak var scrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.nameLabel?.text = self.client.name
        if let avatarImageView = self.avatarImageView {
            let placeholderAvatar = UIImage(named:"userdefault")
            if let avatarUrl = self.client.avatarUrl {
                let filter = ScaledToSizeCircleFilter(size: avatarImageView.frame.size)
                avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: UIImage(named:"userdefault"), filter: filter)
            } else {
                avatarImageView.image = placeholderAvatar?.af_imageAspectScaled(toFit: avatarImageView.frame.size).af_imageRoundedIntoCircle()
            }
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
            avatarImageView.clipsToBounds = true
        }
        self.studentNameTextField?.text = self.subaccount?.name ?? ""
        self.studentNameTextField?.delegate = self
        self.addressTextField?.text = self.subaccount?.address ?? self.client.address ?? ""
        self.addressTextField?.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIViewController.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mapButton = UIBarButtonItem(title: "Abrir Mapa", style: .plain, target: self, action: #selector(openMap))
        //let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self.view, action: #selector(UIView.endEditing(_:)))
        //toolbar.items = [flexSpace, item]
        toolbar.items = [mapButton, flexSpace]
        toolbar.sizeToFit()
        
        self.addressTextField?.inputAccessoryView = toolbar
        
        guard self.locationButton != nil else { return }
        if let location = self.subaccount?.location {
            self.setLocation(location)
        } else if let locationId = self.subaccount?.locationId, locationId > 0 {
            self.service.getLocation(withId: locationId) { [weak self] (result) in
                self?.handleResult(result) {
                    self?.setLocation($0)
                }
            }
        } else if let location = self.client?.location {
            self.setLocation(location)
        } else if let locationId = self.client?.locationId, locationId > 0 {
            self.service.getLocation(withId: locationId) { [weak self] (result) in
                self?.handleResult(result) {
                    self?.setLocation($0)
                }
            }
        } else {
            let text = "Seleccionar Ubicación"
            self.locationButton?.setTitle(text, for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateInstruments(_ instruments: [Instrument]) {
        super.updateInstruments(instruments)
        guard let account = self.subaccount else { return }
        if let selectedValues = account.instruments {
            self.selectInstruments(selectedValues)
        } else {
            let alert = self.showSpinner(withMessage: "Buscando instrumentos del estudiante...")
            self.service.getInstruments(of: account) { [weak self] (result) in
                alert.hideView()
                self?.handleResult(result) {
                    account.instruments = $0
                    self?.selectInstruments($0)
                }
            }
        }
    }
    
    func selectInstruments(_ selectedValues: [Instrument]) {
        guard let instruments = self.instruments else {
            return
        }
        for i in 0..<instruments.count {
            if selectedValues.contains(instruments[i]) {
                let indexPath = IndexPath(item: i, section: 0)
                self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            }
        }
    }
    
    open func validateFields() -> String? {
        if let textField = self.studentNameTextField, (textField.text ?? "").isEmpty {
            return "Por favor, introduce el nombre del estudiante."
        }
        if let textField = self.addressTextField, (textField.text ?? "").isEmpty {
            return "Por favor, introduce la dirección del estudiante."
        }
        if self.locationButton != nil && self.client?.location == nil {
            return "Por favor, selecciona la ubicación del estudiante."
        }
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView?.contentInset = UIEdgeInsets.zero
        } else {
            scrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }
    
    func reset() {
        self.studentNameTextField?.text = ""
        self.collectionView.selectItem(at: nil, animated: true, scrollPosition: .top)
    }
    
    @IBAction func onRegisterSubbacount(_ sender: Any) {
        if let error = self.validateFields() {
            return self.notify(message: error, title: "Información incompleta")
        }
        
        let instruments = self.instruments ?? []
        let selection = self.collectionView.indexPathsForSelectedItems ?? []
        
        let client = Subaccount()
        client.userId = self.client.id
        client.name = self.studentNameTextField?.text ?? ""
        client.address = self.addressTextField?.text
        client.location = self.location ?? self.client.location
        client.locationId = client.location?.id ?? self.client.locationId
        client.instruments = selection.map({instruments[$0.item]})
        
        let alert = self.showSpinner(withMessage: "Registrando estudiante...")
        self.service.registerSubaccount(client) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("SI") {
                    self?.reset()
                }
                alertView.addButton("NO") {
                    self?.performSegue(withIdentifier: "subaccountCreated", sender: sender)
                }
                alertView.showSuccess("El estudiante \(client.name) se ha agregado correctamente", subTitle: "¿Desea Agregar otro estudiante?")
            }
        }
    }
    
    @IBAction func onUpdateSubbacount(_ sender: Any) {
        if let error = self.validateFields() {
            return self.notify(message: error, title: "Información incompleta")
        }
        
        let instruments = self.instruments ?? []
        let selection = self.collectionView.indexPathsForSelectedItems ?? []
        
        let client = self.subaccount!
        client.name = self.studentNameTextField?.text ?? ""
        client.address = self.addressTextField?.text
        client.location = self.location ?? client.location
        client.locationId = client.location?.id ?? client.locationId
        client.instruments = selection.map({instruments[$0.item]})
        
        let alert = self.showSpinner(withMessage: "Actualizando estudiante...")
        self.service.updateSubaccount(client) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("Aceptar") {
                    self?.performSegue(withIdentifier: "subaccountUpdated", sender: sender)
                }
                alertView.showSuccess("Estudiante actualizado", subTitle: "El estudiante \(client.name) se actualizó correctamente")
            }
        }
    }
    
    @IBAction func onRegister(_ sender: Any) {
        if let error = self.validateFields() {
            return self.notify(message: error, title: "Información incompleta")
        }
        
        let instruments = self.instruments ?? []
        let selection = self.collectionView.indexPathsForSelectedItems ?? []
        self.user.instruments = selection.map({instruments[$0.item]})
        
        let alert = self.showSpinner(withMessage: "Registrando...")
        self.service.registerUser(self.user) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                let message = self?.client.facebookId == nil ?
                    "Esperamos que disfrute la experiencia de nuestra aplicación" :
                "Se le enviará un mail con los datos correspondientes para acceder a la aplicación"
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView1 = SCLAlertView(appearance: appearance)
                alertView1.addButton("OK") {
                    self?.performSegue(withIdentifier: "registered", sender: sender)
                }
                alertView1.showSuccess("Gracias por Registrarte", subTitle: message)
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? PasswordResetViewController {
            controller.email = self.client.email
        }
    }
    
    override func unwindBack(_ segue: UIStoryboardSegue) {
        if segue.identifier == "updateAddress", let controller = segue.source as? MapViewController {
            self.addressTextField?.text = controller.selectedAddress
            guard self.locationButton != nil else { return }
            if let address = controller.selectedAddress, !address.isEmpty {
                self.updateLocations { [weak self] locations in
                    self?.locations = locations
                    if locations.count == 1 {
                        self?.setLocation(locations[0])
                    } else if locations.count > 0 {
                        self?.showMapSelectionMenu(withOptions: locations)
                    }
                }
            }
        }
    }
}

extension InstrumentsRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField === self.addressTextField else { return }
        self.updateLocations { [weak self] locations in
            self?.locations = locations
            if locations.count == 1 {
                self?.setLocation(locations[0])
            } else if locations.count > 0 {
                self?.showMapSelectionMenu(withOptions: locations)
            }
        }
    }
}

extension InstrumentsRegistrationViewController {
    @objc func openMap() {
        self.performSegue(withIdentifier: "openMap", sender: nil)
    }
    
    private func setLocation(_ location: Location) {
        self.location = location
        self.locationButton?.setTitle(location.description, for: .normal)
    }
    
    private func showMapSelectionMenu(withOptions locations: [Location]) {
        let selection = locations.firstIndex(where: {$0.id == self.location?.id}) ?? 0
        ActionSheetStringPicker.show(withTitle: "Selecciona tu Ubicación", rows: locations, initialSelection: selection, doneBlock: { (_, index, location) in
            self.setLocation(locations[index])
        }, cancel: { (_) in
            
        }, origin: self.container ?? self)
    }
    
    private func updateLocations(completion: (([Location]) -> ())? = nil) {
        guard self.locationButton != nil else { return }
        guard let address = self.addressTextField?.text, !address.isEmpty else { return }
        let alert = self.showSpinner(withMessage: "Buscando ubicaciones...")
        self.service.getLocations(at: address) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) { locations in
                self?.locations = locations
                completion?(locations)
            }
        }
    }
    
    @IBAction func onSelectLocation(_ sender: Any) {
        guard let address = self.addressTextField?.text, !address.isEmpty else {
            SCLAlertView().showNotice("Acción inválida", subTitle: "Introduzca su dirección antes de seleccionar su ubicación.", closeButtonTitle: "Aceptar")
            return
        }
        if let locations = self.locations {
            switch locations.count {
            case 0:
                SCLAlertView().showNotice("Sin opciones", subTitle: "No se detectaron ubicaciones para su dirección", closeButtonTitle: "Aceptar")
            case 1:
                SCLAlertView().showNotice("Sin opciones", subTitle: "Se encontró solo una ubicación para su dirección", closeButtonTitle: "Aceptar")
            default:
                self.showMapSelectionMenu(withOptions: locations)
            }
        } else {
            self.updateLocations { [weak self] (locations) in
                if locations.count == 1 {
                    self?.setLocation(locations[0])
                } else if locations.count > 0 {
                    self?.showMapSelectionMenu(withOptions: locations)
                }
            }
        }
    }
}

//
//  InstrumentsUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class InstrumentsUpdateViewController: InstrumentListViewController, RegistrationController {
    var user: User!
    
    override var instruments: [Instrument]? {
        didSet {
            guard let clientInstruments = self.user.instruments, let instruments = self.instruments else { return }
            self.collectionView?.selectItem(at: nil, animated: false, scrollPosition: [])
            for index in 0..<instruments.count {
                if clientInstruments.contains(instruments[index]) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let instrument = self.instruments?[indexPath.item] else { return }
        self.user.instruments?.append(instrument)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let instrument = self.instruments?[indexPath.item] else { return }
        self.user.instruments?.removeAll(where: {$0 == instrument})
    }
    
    @IBAction func onSaveChanges(_ sender: Any) {
        guard self.user.instruments != self.service.user?.instruments else {
            return notify(message: "No hay cambios que guardar.", title: "Error")
        }
        
        let alert = self.showSpinner(withMessage: "Actualizando cambios...")
        let user = self.user!
        self.service.updateUser(user) { (result) in
            alert.hideView()
            self.handleResult(result) {
                self.user = $0
                SCLAlertView()
                    .showSuccess("Cuenta Actualizada",
                                 subTitle: "La configuración de su cuenta se actualizó correctamente.",
                                 closeButtonTitle: "Aceptar")
                    .setDismissBlock { [weak self] in
                        self?.goBack()
                }
            }
        }
    }
}

//
//  InstrumentsUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

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
}

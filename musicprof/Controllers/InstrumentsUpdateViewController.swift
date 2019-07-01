//
//  InstrumentsUpdateViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

class InstrumentsUpdateViewController: InstrumentListViewController {
    override var instruments: [Instrument]? {
        didSet {
            guard let clientInstruments = self.client.instruments, let instruments = self.instruments else { return }
            for index in 0..<instruments.count {
                if clientInstruments.contains(instruments[index]) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
            
        }
    }
}

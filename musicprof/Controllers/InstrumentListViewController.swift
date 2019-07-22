//
//  InstrumentListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class InstrumentListViewController: BaseNestedViewController {    
    var instruments: [Instrument]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateInstruments()
    }
    
    open func updateInstruments() {
        let alert = self.showSpinner(withMessage: "Buscando instrumentos...")
        self.service.getInstruments { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                self?.updateInstruments($0)
            }
        }
    }
    
    open func updateInstruments(_ instruments: [Instrument]) {
        self.instruments = instruments
    }
}

extension InstrumentListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.instruments?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "instrumentCell", for: indexPath) as! InstrumentCell
        let instrument = self.instruments?[indexPath.row]
        if let iconURL = instrument?.iconUrl {
            var filter: ImageFilter = ScaledToSizeFilter(size: cell.iconImageView.frame.size)
            filter = TemplateFilter()
            cell.iconImageView.af_setImage(withURL: iconURL, filter: filter)
        } else {
            cell.iconImageView.image = UIImage(named: "no_instrument")
        }
        cell.updateColors()
        
        return cell
    }
}

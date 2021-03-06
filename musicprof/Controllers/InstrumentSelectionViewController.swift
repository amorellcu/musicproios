//
//  InstrumentSelectionViewController.swift
//  musicprof
//
//  Created by John Doe on 6/22/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView
import AlamofireImage

class InstrumentSelectionViewController: BaseReservationViewController {
    let expandedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    let collapsedColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
    let prototypeCellIdentifier = "instrumentCell"
    
    var userInstruments: [Instrument] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var instruments: [Instrument]? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var studentsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let instruments = self.student?.instruments {
            self.userInstruments = instruments
            self.updateInstruments()
        } else if let student = self.student {
            let alert = self.showSpinner(withMessage: "Buscando instrumentos...")
            self.service.getInstruments(of: student) { [weak self] (result) in
                alert.hideView()
                self?.handleResult(result) {
                    self?.userInstruments = $0
                    self?.updateInstruments()
                }
            }
        } else {
            self.updateInstruments()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateInstruments() {
        let alert = self.showSpinner(withMessage: "Buscando instrumentos...")
        self.service.getInstruments { [weak self] (result: ApiResult<[Instrument]>) in
            alert.hideView()
            self?.handleResult(result) {
                guard let strongSelf = self else { return }
                let otherInstruments = Array(Set($0).subtracting(strongSelf.userInstruments))
                strongSelf.instruments = strongSelf.userInstruments + otherInstruments.sorted(by: {$0.id <= $1.id})
            }
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}

extension InstrumentSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    private func instruments(fromSection section: Int) -> [Instrument]? {
        switch section {
        //case 0:
        //    return self.userInstruments
        default:
            return self.instruments
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.instruments(fromSection: section)?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: prototypeCellIdentifier, for: indexPath) as! InstrumentCell
        let instrument = self.instruments(fromSection: indexPath.section)?[indexPath.row]
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.continueButton.isEnabled = true
        self.reservation.instrument = self.instruments(fromSection: indexPath.section)?[indexPath.row]
    }
}

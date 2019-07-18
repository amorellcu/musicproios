//
//  ClassInstrumentSelectionViewController.swift
//  musicprof
//
//  Created by John Doe on 7/15/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView
import AlamofireImage

class ClassInstrumentSelectionViewController: BaseNestedViewController, ClassController {
    let expandedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    let collapsedColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
    let prototypeCellIdentifier = "instrumentCell"
    
    var reservation: ClassRequest!
    
    var instruments: [Instrument]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.instruments = self.service.currentProfessor?.instruments
        if self.instruments?.count ?? 0 == 1 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            self.collectionView(self.collectionView, didSelectItemAt: indexPath)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? ClassController {
            controller.reservation = self.reservation
        }
    }
}

extension ClassInstrumentSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        self.reservation.instrumentId = self.reservation.instrument?.id
    }
}

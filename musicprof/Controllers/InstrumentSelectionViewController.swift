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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectInstrumentsButton: UIButton!
    @IBOutlet weak var addStudentsButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var studentsView: UIView!
    
    @IBOutlet weak var collectionViewCollapseConstraint: NSLayoutConstraint?
    @IBOutlet weak var studentsViewCollapseConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let instruments = self.service.user?.instruments {
            self.userInstruments = instruments
        }
        
        self.updateInstruments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateInstruments() {
        self.service.getInstruments { [weak self] (result: ApiResult<[Instrument]>) in
            self?.handleResult(result) {
                guard let strongSelf = self else { return }
                strongSelf.instruments = Array(Set($0).subtracting(strongSelf.userInstruments))
            }
        }
    }
    
    @IBAction func onAddStudentsTapped(_ sender: UIButton) {
        self.studentsViewCollapseConstraint?.priority = .defaultLow
        self.collectionViewCollapseConstraint?.priority = .defaultHigh
        UIView.animate(withDuration: 0.5) {
            self.scrollView.layoutIfNeeded()
        }
    }
    
    @IBAction func onSelectInstrumentTapped(_ sender: UIButton) {
        self.collectionViewCollapseConstraint?.priority = .defaultLow
        self.studentsViewCollapseConstraint?.priority = .defaultHigh
        UIView.animate(withDuration: 0.5) {
            self.scrollView.layoutIfNeeded()
        }
    }
    
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nestedController = segue.destination as? AddStudentsViewController {
            nestedController.parentController = self
            nestedController.scrollView = self.scrollView
        }
        super.prepare(for: segue, sender: sender)
    }
}

extension InstrumentSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    private func instruments(fromSection section: Int) -> [Instrument]? {
        switch section {
        case 0:
            return self.userInstruments
        default:
            return self.instruments
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.instruments == nil ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.instruments(fromSection: section)?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: prototypeCellIdentifier, for: indexPath) as! InstrumentCollectionViewCell
        let instrument = self.instruments(fromSection: indexPath.section)?[indexPath.row]
        if let iconURL = instrument?.iconUrl {
            let filter: ImageFilter = ScaledToSizeFilter(size: cell.instrumentIcon.frame.size)
            cell.instrumentIcon.af_setImage(withURL: iconURL, filter: filter)
        } else {
            cell.instrumentIcon.image = UIImage(named: "no_instrument")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.continueButton.isEnabled = true
        self.reservation.instrument = self.instruments(fromSection: indexPath.section)?[indexPath.row]
    }
}

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
    var instruments: [Instrument] = [] {
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
            self.instruments = instruments
        } else {
            self.service.getUserInfo { [weak self] (result) in
                self?.handleResult(result) { data in
                    self?.instruments = data.instruments ?? []
                }
            }
        }        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.instruments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: prototypeCellIdentifier, for: indexPath) as! InstrumentCollectionViewCell
        if let iconURL = self.instruments[indexPath.row].iconUrl {
            let filter: ImageFilter = ScaledToSizeFilter(size: cell.instrumentIcon.frame.size)
            cell.instrumentIcon.af_setImage(withURL: iconURL, filter: filter)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.continueButton.isEnabled = true
        self.reservation.instrument = self.instruments[indexPath.row]
    }
}

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

class InstrumentSelectionViewController: UIViewController {
    let alertView = SCLAlertView()
    let prototypeCellIdentifier = "instrumentCell"
    var instruments: [Instrument] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var perfilImage: UIImageView!
    @IBOutlet weak var PerfilName: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var selectInstrumentsButton: UIButton!
    @IBOutlet weak var addStudentsButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var collectionViewCollapseConstraint: NSLayoutConstraint?
    
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
        
        // Do any additional setup after loading the view.
        self.PerfilName.text = self.service.user?.name
        let placeholderAvatar = UIImage(named:"userdefault")
        if let avatarUrl = self.service.user?.avatarUrl {
            self.perfilImage.af_setImage(withURL: avatarUrl, placeholderImage: UIImage(named:"userdefault"))
        } else {
            self.perfilImage.image = placeholderAvatar
        }
        self.perfilImage.layer.cornerRadius = self.perfilImage.frame.size.width / 2
        self.perfilImage.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddStudents(_ sender: Any) {
        
    }
    
    @IBAction func onSelectInstrumentTapped(_ sender: UIButton) {
        self.collectionViewCollapseConstraint?.isActive = false
        UIView.animate(withDuration: 0.5) {
            self.scrollview.layoutIfNeeded()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
    }
}

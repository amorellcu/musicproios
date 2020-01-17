//
//  ProfessorListViewController.swift
//  musicprof
//
//  Created by John Doe on 6/24/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class ProfessorListViewController: BaseReservationViewController {
    let prototypeCellIdentifier = "professorCell"
    let priceFormatter = NumberFormatter()
    var professors: [Professor] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func loadView() {
        self.priceFormatter.locale = Locale(identifier: "es")
        self.priceFormatter.numberStyle = .currency
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: get professors
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfessorListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.professors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: prototypeCellIdentifier, for: indexPath) as! ProfessorCell
        let professor = self.professors[indexPath.row]
        if let iconURL = professor.avatarUrl {
            let filter: ImageFilter = AspectScaledToFillSizeCircleFilter(size: cell.avatarImageView.frame.size)
            cell.avatarImageView.af_setImage(withURL: iconURL, filter: filter)
        }
        if let price = professor.price {
            cell.priceLabel.text = self.priceFormatter.string(from: NSNumber(value: price))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.reservation.professor = self.professors[indexPath.row]
    }
}

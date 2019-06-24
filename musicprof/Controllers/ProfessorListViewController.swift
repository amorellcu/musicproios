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
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UILabel!
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
        
        // Do any additional setup after loading the view.
        self.nameTextField.text = self.service.user?.name
        let placeholderAvatar = UIImage(named:"userdefault")
        if let avatarUrl = self.service.user?.avatarUrl {
            self.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: UIImage(named:"userdefault"))
        } else {
            self.avatarImageView.image = placeholderAvatar
        }
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.clipsToBounds = true
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
        if let iconURL = professor.iconUrl {
            let filter: ImageFilter = ScaledToSizeCircleFilter(size: cell.avatarImageView.frame.size)
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

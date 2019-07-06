//
//  InstrumentListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/1/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import AlamofireImage

class InstrumentListViewController: UIViewController, RegistrationController, NestedController {
    var container: ContainerViewController?
    var client: Client!
    
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
        self.updateInstruments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    open func updateInstruments() {
        self.service.getInstruments { [weak self] (result) in
            self?.handleResult(result) {
                self?.updateInstruments($0)
            }
        }
    }
    
    open func updateInstruments(_ instruments: [Instrument]) {
        self.instruments = instruments
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? RegistrationController {
            controller.client = self.client
        }
        if let controller = segue.destination as? NestedController {
            controller.container = self.container
        }
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

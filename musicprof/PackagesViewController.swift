//
//  PackagesViewController.swift
//  musicprof
//
//  Created by Alexis Morell on 03/05/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class PackagesViewController: UIViewController, NestedController {
    var container: ContainerViewController?
    
    var packages: [Package]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.container?.setDisplayMode(.picture, animated: animated)
        self.service.getPackages { (result) in
            self.handleResult(result) {
                self.packages = $0
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension PackagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let packages = self.packages else { return UITableViewCell() }
        let package = packages[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "packageCell") as! PackageCell
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "es-US")
        cell.quantityLabel.text = formatter.string(from: NSNumber(value: package.quantity))
        cell.expirationLabel.text = package.expiresOn == nil ? "" : "Expira: \(package.expiresOn) días."
        formatter.numberStyle = .currency
        let priceStr = (package.price == nil ? nil : formatter.string(from: NSNumber(value: package.price!))) ?? ""
        let rightAlign = NSMutableParagraphStyle()
        rightAlign.alignment = .right
        
        
        var attrText = NSMutableAttributedString(string: "CLASES  ", attributes: [NSAttributedString.Key.font: UIFont(name: "FilsonProRegular", size: 10)])
        attrText.append(NSAttributedString(string: priceStr, attributes: [NSAttributedString.Key.font: UIFont(name: "FilsonProHeavy", size: 14)]))
        
        cell.detailsLabel.attributedText = attrText
        
        return cell
    }
    
    
}

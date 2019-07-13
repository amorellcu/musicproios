//
//  PackagesViewController.swift
//  musicprof
//
//  Created by Alexis Morell on 03/05/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import Braintree
import SCLAlertView

class PackagesViewController: BaseNestedViewController {
    
    var braintreeClient: BTAPIClient?
    
    var packages: [Package]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.service.getPaypalToken { (result) in
            self.handleResult(result) {
                self.braintreeClient = BTAPIClient(authorization: $0)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.container?.setDisplayMode(.picture, animated: animated)
        
        if let location = self.service.currentClient?.location {
            self.updatePackages(from: location)
        } else if let locationId = self.service.currentClient?.locationId {
            self.service.getLocation(withId: locationId) { (result) in
                self.handleResult(result) {
                    self.updatePackages(from: $0)
                }
            }
        }
    }
    
    func updatePackages(from location: Location) {
        self.service.getPackages(forStateWithId: location.stateId) { (result) in
            self.handleResult(result) {
                self.packages = $0
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func buyPackage(_ package: Package) {
        self.tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        
        guard let client = self.braintreeClient, let amount = package.price else { return }
        
        let driver = BTPayPalDriver(apiClient: client)
        driver.viewControllerPresentingDelegate = self
        driver.appSwitchDelegate = self
        
        let request = BTPayPalRequest(amount: String(describing: amount))
        request.currencyCode = "MXN"
        request.localeCode = "es-MX"
        request.lineItems = [BTPayPalLineItem(quantity: "1", unitAmount: package.priceStr,
                                              name: package.quantity == 1 ? "Paquete de 1 clase." : "Paquete de \(package.quantity) clases.",
                                              kind: .debit)]
        
        driver.requestOneTimePayment(request) { (account, error) in
            if let account = account {
                self.pay(forPackage: package, withToken: account)
            } else if let error = error {
                self.notify(error: error)
            } else {
                print("Payment canceled.")
            }
        }
    }
    
    private func pay(forPackage package: Package, withToken token: BTPayPalAccountNonce) {
        print("Got a nonce: \(token.nonce)")
        let alert = self.showSpinner(withMessage: "Completando transacción...")
        self.service.performPaypalPayment(for: package, withToken: token.nonce, handler: { (result) in
            alert.hideView()
            self.handleResult(result) {
                if let client = self.service.currentClient, let credits = client.credits {
                    client.credits = credits + package.quantity
                }
                self.container?.refresh()
                SCLAlertView().showSuccess("Paquete Adquirido",
                                           subTitle: package.quantity == 1 ? "Ahora puede reservar 1 clase más." : "Ahora puede reservar \(package.quantity) clases más.")
            }
        })
    }
}

extension PackagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packages?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let packages = self.packages else { return tableView.dequeueReusableCell(withIdentifier: "loadingCell")! }
        let package = packages[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "packageCell") as! PackageCell
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "es-US")
        cell.quantityLabel.text = formatter.string(from: NSNumber(value: package.quantity))
        cell.expirationLabel.text = package.expiresOn == nil ? "" : "Expira: \(package.expiresOn!) días."
        formatter.numberStyle = .currency
        let priceStr = (package.price == nil ? nil : formatter.string(from: NSNumber(value: package.price!))) ?? ""
        let rightAlign = NSMutableParagraphStyle()
        rightAlign.alignment = .right
        
        
        var attrText = NSMutableAttributedString(string: "CLASES  ", attributes: [NSAttributedString.Key.font: UIFont(name: "FilsonProRegular", size: 10)])
        attrText.append(NSAttributedString(string: priceStr, attributes: [NSAttributedString.Key.font: UIFont(name: "FilsonProHeavy", size: 14)]))
        
        cell.detailsLabel.attributedText = attrText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return self.braintreeClient == nil || self.packages == nil ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let packages = self.packages else { return }
        let package = packages[indexPath.item]
        self.buyPackage(package)
    }
}

extension PackagesViewController: BTViewControllerPresentingDelegate, BTAppSwitchDelegate {
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        if self.navigationController?.viewControllers.last != viewController {
            self.navigationController?.popToViewController(viewController, animated: false)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
    }
}

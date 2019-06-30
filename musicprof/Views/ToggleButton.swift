//
//  ToggleButton.swift
//  musicprof
//
//  Created by John Doe on 6/30/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

@IBDesignable class ToggleButton: UIView {
    let checkedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    let normalColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBInspectable var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }
    
    @IBInspectable var isChecked = true {
        didSet {
            self.updateState()
        }
    }
    
    let nibName = "ToggleButton"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        self.updateState()
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        self.updateState()
    }
    
    private func updateState() {
        if !isChecked {
            textLabel.textColor = normalColor
            leftImageView?.image = UIImage(named: "fleizqoff")
            rightImageView?.image = UIImage(named: "flederoff")
        } else {
            textLabel.textColor = checkedColor
            leftImageView?.image = UIImage(named: "flechaizq")
            rightImageView?.image = UIImage(named: "flechader")
        }
    }
}

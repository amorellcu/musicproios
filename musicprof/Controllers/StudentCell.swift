//
//  StudentCell.swift
//  musicprof
//
//  Created by John Doe on 6/23/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    weak var delegate: StudentCellDelegate?
    var indexPath: IndexPath?

    @IBAction func onRemoveTapped(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        self.delegate?.studentCell(self, removeFrom: indexPath)
    }
}

protocol StudentCellDelegate: class {
    func studentCell(_ cell: StudentCell, removeFrom: IndexPath)
}

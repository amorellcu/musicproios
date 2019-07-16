//
//  ClassSchedulingViewController.swift
//  musicprof
//
//  Created by John Doe on 7/16/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView

class ClassSchedulingViewController: BaseNestedViewController, ClassController {
    var reservation: ClassRequest!
    
    var date: Date!
    
    @IBOutlet weak var dateLabel: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var confirmButton: TransparentButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let date = self.reservation.date {
            self.date = self.calendar.startOfDay(for: date)
            let formatter = DateFormatter()
            formatter.calendar = self.calendar
            formatter.locale = self.calendar.locale
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            
            let dateStr = formatter.string(from: date)
            self.dateLabel.setTitle(dateStr, for: .normal)
            self.dateLabel.setTitle(dateStr, for: .disabled)
        }
        
        self.configure(picker: self.timePicker)
    }
    
    func configure(picker: UIDatePicker) {
        let now = Date()
        let today = self.calendar.startOfDay(for: now)
        let time = now.timeIntervalSince(today)
        picker.date = self.date.addingTimeInterval(time)
        picker.minimumDate = self.calendar.date(byAdding: .hour, value: 8, to: self.date)
        picker.maximumDate = self.calendar.date(byAdding: .hour, value: 20, to: self.date)
        picker.setValue(UIColor.white, forKeyPath: "textColor")
        picker.setValue(false, forKey: "highlightsToday")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.container?.setDisplayMode(.full, animated: animated)
    }    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? ClassController {
            controller.reservation = self.reservation
        }
    }
    
    @IBAction func onConfirmTapped(_ sender: Any) {
        var reservation = self.reservation!
        reservation.date = self.timePicker.date
        let alert = self.showSpinner(withMessage: "Reservando clase...")
        self.service.createClass(reservation) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                SCLAlertView().showSuccess("Reservado", subTitle: "La clase se creó satisfactoriamente.")
                self?.performSegue(withIdentifier: "classCreated", sender: sender)
            }
        }
    }
}

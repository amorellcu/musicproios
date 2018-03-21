//
//  CalendarViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 13/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import JTAppleCalendar

protocol MonthViewDelegate {
    func didChangeMonth(monthIndex: Int)
}

class CalendarViewController: UIViewController {

    @IBOutlet weak var days: UIView!
    @IBOutlet weak var perfil: UIImageView!
    @IBOutlet weak var namePerfil: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var month: UILabel!
    
    let formatter = DateFormatter()
    let outsideDayColor = UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1)
    let dayColor = UIColor(red: 255/255 ,green: 210/255 ,blue: 69/255 ,alpha: 1)
    let selectedDayColor = UIColor(red: 65/255 ,green: 64/255 ,blue: 66/255 ,alpha: 1)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.perfil.layer.cornerRadius = self.perfil.frame.size.width / 2
        self.perfil.clipsToBounds = true
        self.days.layer.cornerRadius = 28
        self.days.clipsToBounds = true
        setupCalendarView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    var dict = result as! [String : AnyObject]
                    var data = dict["picture"]!["data"] as! [String : AnyObject]
                    let imageUrlString = data["url"] as! String
                    let imageUrl:URL = URL(string: imageUrlString)!
                    
                    // Start background thread so that image loading does not make app unresponsive
                    DispatchQueue.global(qos: .userInitiated).async {
                        let imageData:NSData = NSData(contentsOf: imageUrl)!
                        // When from background thread, UI needs to be updated on main_queue
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData as Data)
                            self.perfil.image = image
                            self.namePerfil.text = dict["name"] as? String
                        }
                    }
                }
            })
        }
    }

    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.visibleDates{ visibleDates in
            self.setupViewOfCalendar(from: visibleDates)
        }
    }
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CalendarCell else { return }
        if cellState.isSelected{
            if (cellState.dateBelongsTo == .thisMonth) {
                validCell.dateLabel.textColor = selectedDayColor
            }
            else{
                validCell.dateLabel.textColor = outsideDayColor
            }
        }
        else{
            if cellState.dateBelongsTo == .thisMonth{
                validCell.dateLabel.textColor = dayColor
            }
            else{
                validCell.dateLabel.textColor = outsideDayColor
            }
            
        }
    }
    
    func handleCellViewSelected(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CalendarCell else { return }
        if validCell.isSelected{
            if (cellState.dateBelongsTo == .thisMonth) {
                validCell.selectedView.isHidden = false
                self.performSegue(withIdentifier: "calendarSegue", sender: self)
            }
            else{
                validCell.selectedView.isHidden = true
            }
        }
        else{
            validCell.selectedView.isHidden = true
        }
    }
    
    func setupViewOfCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date).uppercased()
    }
    
   
    @IBAction func previosMonth(_ sender: Any) {
        calendarView.scrollToSegment(.previous)
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        calendarView.scrollToSegment(.next)
    }
    
    
  
    
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let name = self.namePerfil.text
        let photo = self.perfil.image
        if(segue.identifier == "calendarSegue"){
            let Instruments = segue.destination as? ScheduleViewController
            if(name != nil){
                Instruments?.Perfilname = name!
            }
            if(photo != nil){
                Instruments?.photoPerfil = photo!
            }
        }
        
    }


}

extension CalendarViewController: JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        let currentDay = Date()
        let currentDateString = formatter.string(from: currentDay)
        let lastDay = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        let lasttDateString = formatter.string(from: lastDay!)
        let startDate = formatter.date(from: currentDateString)!
        let endDate = formatter.date(from: lasttDateString)!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameters
    }
}


extension CalendarViewController: JTAppleCalendarViewDelegate{
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {

    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calendarcell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        handleCellViewSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellViewSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellViewSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewOfCalendar(from: visibleDates)
    }

    
    
}


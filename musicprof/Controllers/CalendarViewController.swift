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
import AlamofireImage

protocol MonthViewDelegate {
    func didChangeMonth(monthIndex: Int)
}

class CalendarViewController: BaseReservationViewController, UITabBarDelegate {

    @IBOutlet weak var daysView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var proceedButton: UIButton!
    
    let outsideDayColor = UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1)
    let dayColor = UIColor(red: 255/255 ,green: 210/255 ,blue: 69/255 ,alpha: 1)
    let selectedDayColor = UIColor(red: 65/255 ,green: 64/255 ,blue: 66/255 ,alpha: 1)
    
    var startDate: Date!
    var endDate: Date!
    var selectedDate: Date? {
        didSet {
            self.reservation.date = self.selectedDate
            self.proceedButton.isEnabled = self.selectedDate != nil
        }
    }
    var validDates = [Int: [Date]]() {
        didSet {
            self.calendarView.reloadData()
        }
    }
    
    override func loadView() {
        self.startDate = self.calendar.startOfDay(for: Date())
        self.endDate = self.calendar.date(byAdding: .month, value: 3, to: self.startDate)
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.daysView.layer.masksToBounds = true
        
        setupCalendarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.container?.setDisplayMode(.full, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateValidDates(forMonth month: Int) {
        self.service.getAvailableDays(for: self.reservation, inMonth: month) { [weak self] (result) in
            self?.handleResult(result) {
                guard let stronSelf = self else { return }
                stronSelf.validDates[month] = $0.map { stronSelf.calendar.startOfDay(for: $0) }
            }
        }
    }
    
    private func isDateValid(_ date: Date) -> Bool {
        guard (self.startDate...self.endDate).contains(date) else { return false }
        let month = self.calendar.component(.month, from: date)
        return self.validDates[month]?.contains(date) ?? false
        //return true
    }

    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.isRangeSelectionUsed = false
        calendarView.visibleDates{ visibleDates in
            self.updateMonthLabel(from: visibleDates)
        }
    }
    
    func updateMonthLabel(from visibleDates: DateSegmentInfo){
        guard let date = visibleDates.monthDates.first?.date else {
            self.monthLabel.text = ""
            return
        }
        let month = self.calendar.component(.month, from: date)
        let monthName = self.calendar.monthSymbols[month - 1]
        self.monthLabel.text = monthName.uppercased()
        
        self.previousMonthButton.isEnabled = !visibleDates.monthDates.contains(where: {$0.date == self.startDate})
        self.nextMonthButton.isEnabled = !visibleDates.monthDates.contains(where: {$0.date == self.endDate})
        
        if self.validDates[month] == nil {
            self.updateValidDates(forMonth: month)
        }
    }
    
   
    @IBAction func onPreviousMonthTapped(_ sender: Any) {
        self.calendarView.scrollToSegment(.previous)
    }
    
    @IBAction func onNextMonthTapped(_ sender: Any) {
        self.calendarView.scrollToSegment(.next)
    }
    
    @IBAction func onProceedTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "selectTime", sender: calendar)
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    private func configureCell(_ cell: JTAppleCell, forDate date: Date, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.dateLabel.text = cellState.text
        if cellState.isSelected {
            cell.dateLabel.textColor = self.selectedDayColor
            cell.selectedView.backgroundColor = self.dayColor
        } else if cellState.dateBelongsTo == .thisMonth && self.isDateValid(date) {
            cell.dateLabel.textColor = self.dayColor
            cell.selectedView.backgroundColor = UIColor.clear
        } else {
            cell.dateLabel.textColor = self.outsideDayColor
            cell.selectedView.backgroundColor = UIColor.clear
        }
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: self.startDate, endDate: self.endDate, numberOfRows: 6, calendar: self.calendar,
                                       generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow,
                                       firstDayOfWeek: .sunday, hasStrictBoundaries: true)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        self.configureCell(cell, forDate: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calendarcell", for: indexPath) as! CalendarCell
        self.configureCell(cell, forDate: date, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return self.isDateValid(date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell else { return }
        self.selectedDate = date
        self.configureCell(cell, forDate: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if self.selectedDate == date {
            self.selectedDate = nil
        }
        guard let cell = cell else { return }
        self.configureCell(cell, forDate: date, cellState: cellState)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.updateMonthLabel(from: visibleDates)
    }
}


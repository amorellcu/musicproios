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

class CalendarViewController: UIViewController,UITabBarDelegate {

    @IBOutlet weak var days: UIView!
    @IBOutlet weak var perfil: UIImageView!
    @IBOutlet weak var namePerfil: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var tabbar: UITabBar!
    
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var ai: UIActivityIndicatorView!
    @IBAction func onCloseTapped(_ sender: UIButton) {
        self.onLogoutAction(activityIndicator: ai, closeIcon: closeIcon)
    }
    
    //var Perfilname = ""
    //var user: NSDictionary = [:]
    
    let formatter = DateFormatter()
    let outsideDayColor = UIColor(red: 124/255 ,green: 124/255 ,blue: 124/255 ,alpha: 1)
    let dayColor = UIColor(red: 255/255 ,green: 210/255 ,blue: 69/255 ,alpha: 1)
    let selectedDayColor = UIColor(red: 65/255 ,green: 64/255 ,blue: 66/255 ,alpha: 1)
    var dateclass: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSpinner(onView: self.perfil)
        // Do any additional setup after loading the view.
        tabbar.delegate = self
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
        self.namePerfil.text = self.api.nameclient
        let data = self.api.user["data"] as? [String: Any]
        let cliente = data!["client"] as? [String: Any]
        let subaccounts = cliente!["subaccounts"] as! NSArray
        let user = cliente!["user"] as? [String: Any]
        //let photo = user!["photo"] as! String
        //self.perfil.image = UIImage(named: "userdefault")
        if let photo = self.api.urlphoto {
            print("vvvvvv"+photo)
            let url = URL(string: photo)
            self.perfil.af_setImage(withURL: url!){res in
                self.removeSpinner()
            }
//            DispatchQueue.global().async {
//                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                if(data != nil){
//                    DispatchQueue.main.async {
//                        self.perfil.image = UIImage(data: data!)
//                        self.removeSpinner()
//                    }
//                } else {
//                    self.perfil.image = UIImage(named: "userdefault")
//                    self.removeSpinner()
//                }
//
//            }
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
        if cellState.isSelected{
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
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.title! == "paquetes"){
            self.performSegue(withIdentifier: "paquetesSegue", sender: self)
        }
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
            Instruments?.user = self.api.user
            Instruments?.dateclass = self.dateclass
        }
        if(segue.identifier == "paquetesSegue") {
            let Packages = segue.destination as? PackagesViewController
            Packages?.Perfilname = name!
            Packages?.Photo = photo!
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
        self.dateclass = date
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


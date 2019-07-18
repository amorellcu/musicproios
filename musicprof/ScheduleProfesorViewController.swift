//
//  ScheduleProfesorViewController.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 23/02/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import SCLAlertView
import AlamofireImage

class ScheduleProfesorViewController: BaseReservationViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UIButton!
    
    let expandedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    let collapsedColor = UIColor(red: 1, green: 210/255, blue: 69/255, alpha: 1)
    
    var date: Date!
    
    var sections: [Section]? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var selectedSection: Int? {
        didSet {
            if let sections = sections, let selectedSection = selectedSection {
                self.reservation.date = sections[selectedSection].date
            }
            self.collectionView.reloadData()
        }
    }
    
    var selectedClass: Class? {
        didSet {
            if let sections = sections, let selectedSection = selectedSection {
                self.reservation.date = sections[selectedSection].date
            }
            self.reservation.classes = self.selectedClass
            self.reservation.professor = self.selectedClass?.professor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        self.updateSections()
        //self.setDefaultSections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSections(){
        guard var date = self.date else { return }
        
        let formatter = DateFormatter()
        formatter.calendar = self.calendar
        formatter.locale = self.calendar.locale
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        date = self.calendar.startOfDay(for: date)
        let alert = self.showSpinner(withMessage: "Buscando clases disponibles...")
        let range = self.date..<self.calendar.date(byAdding: .day, value: 1, to: self.date)!
        self.service.getAvailableProfessors(for: self.reservation, inDay: date) { [weak self] (result) in
            alert.hideView()
            self?.handleResult(result) {
                var classes = [Date:[Class]]()
                for professor in $0 {
                    for item in professor.classes ?? [] {
                        guard range.contains(item.date), item.status != .cancelled else { continue }
                        var reservation = item
                        reservation.professor = professor
                        var items = classes[reservation.date] ?? []
                        items.append(reservation)
                        classes[reservation.date] = items
                    }
                }
                
                self?.sections = classes.sorted(by: {$0.key <= $1.key}).map {
                    let date = $0.key
                    let name = formatter.string(from: date)
                    return Section(name: name, date: date, items: $0.value)
                }
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? ProfessorDetailsViewController, let sections = self.sections, let selection = self.selectedSection {
            controller.classes = sections[selection].items
        }
    }
    
    struct Section: Equatable {var name: String
        var date: Date
        var items: [Class]
        
        static func == (lhs: ScheduleProfesorViewController.Section, rhs: ScheduleProfesorViewController.Section) -> Bool {
            return lhs.date == rhs.date
        }
    }
}

extension ScheduleProfesorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = self.sections else { return 0 }
        return section == self.selectedSection ? sections[section].items.count + 1 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sections = self.sections else { return UICollectionViewCell() }
        if indexPath.row > 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "professorCell", for: indexPath) as! ProfessorCell
            guard let index = self.selectedSection else { return cell }
            let classes = sections[index].items[indexPath.row - 1]
            let placeholder = UIImage(named: "profesor")?.af_imageRoundedIntoCircle()
            if let iconURL = classes.professor?.avatarUrl {
                let filter: ImageFilter = ScaledToSizeCircleFilter(size: cell.avatarImageView.frame.size)
                cell.avatarImageView.af_setImage(withURL: iconURL, placeholderImage: placeholder, filter: filter)
            } else {
                cell.avatarImageView.image = placeholder
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
            cell.textLabel.text = sections[indexPath.section].name
            cell.textLabel.backgroundColor = indexPath.section == self.selectedSection ? self.expandedColor : self.collapsedColor
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sections = self.sections else { return }
        if indexPath.row > 0 {
            self.selectedClass = sections[indexPath.section].items[indexPath.row - 1]
            self.performSegue(withIdentifier: "selectProfessor", sender: collectionView)
        } else {
            self.selectedSection = indexPath.section
            self.selectedClass = nil
            UIView.animate(withDuration: 0.5, animations: {
                collectionView.layoutIfNeeded()
            })
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
}

class ScheduleLayout: UICollectionViewLayout {
    let sectionHeaderHeight: CGFloat = 50
    let sectionHeaderPadding: CGSize = CGSize(width: 5, height: 5)
    let itemSize: CGSize = CGSize(width: 50, height: 50)
    let itemPadding: CGSize = CGSize(width: 10, height: 5)
    
    fileprivate var cache = [IndexPath: UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        cache = [:]
        guard let collectionView = self.collectionView else { return }
        
        let itemWidth = itemPadding.width * 2 + itemSize.width
        let itemHeight = itemPadding.height * 2 + itemSize.height
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        func processSectionHeader(row: Int, section: Int) {
            let indexPath = IndexPath(row: row, section: section)
            
            let height = sectionHeaderPadding.height * 2 + sectionHeaderHeight
            let frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: height)
            let insetFrame = frame.insetBy(dx: sectionHeaderPadding.width, dy: sectionHeaderPadding.height)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache[indexPath] = attributes
            
            yOffset += height
        }
        
        func processSectionItem(row: Int, section: Int) {
            let indexPath = IndexPath(row: row, section: section)
            
            let height = itemHeight
            let frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: height)
            let insetFrame = frame.insetBy(dx: itemPadding.width, dy: itemPadding.height)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache[indexPath] = attributes
            
            xOffset += itemWidth
            if xOffset + itemWidth > contentWidth {
                xOffset = 0
                yOffset += height
            }
        }
        
        for section in 0 ..< collectionView.numberOfSections {
            let itemCount = collectionView.numberOfItems(inSection: section)
            guard itemCount > 0 else { continue }
            
            processSectionHeader(row: 0, section: section)
            
            for row in 1 ..< itemCount {
                processSectionItem(row: row, section: section)
            }
            
            if xOffset > 0 {
                xOffset = 0
                yOffset += itemHeight
            }
        }
        
        self.contentHeight = yOffset
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
       
        for attributes in cache.values {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath]
    }
}

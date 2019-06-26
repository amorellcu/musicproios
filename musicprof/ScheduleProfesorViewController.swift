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
    
    let collapsedColor = UIColor(red: 0/255 ,green: 255/255 ,blue: 180/255 ,alpha: 1)
    
    var sections: [Section]? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var selectedSection: Int? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var selectedProfessor: Professor? {
        didSet {
            self.reservation.professor = self.selectedProfessor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let date = self.reservation.date {
            let formatter = DateFormatter()
            formatter.calendar = self.calendar
            formatter.locale = self.calendar.locale
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            
            let dateStr = formatter.string(from: date)
            self.dateLabel.setTitle(dateStr, for: .normal)
            self.dateLabel.setTitle(dateStr, for: .disabled)
        }
        
        //self.updateSections()
        self.setDefaultSections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.container?.setDisplayMode(.full, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDefaultSections() {
        guard var date = self.reservation.date else { return }
        
        let formatter = DateFormatter()
        formatter.calendar = self.calendar
        formatter.locale = self.calendar.locale
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        
        let professors = [Professor(id: 0, name: "Jon Snow"), Professor(id: 1, name: "Daenerys Targaryen")]
        var sections = [Section]()
        for i in 8...17 {
            let date = self.calendar.date(byAdding: .hour, value: i, to: date)!
            let name = formatter.string(from: date)
            let section = Section(name: name, date: date, items: professors)
            sections.append(section)
        }
        self.sections = sections
    }
    
    func updateSections(){
        guard var date = self.reservation.date else { return }
        
        let formatter = DateFormatter()
        formatter.calendar = self.calendar
        formatter.locale = self.calendar.locale
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        
        date = self.calendar.startOfDay(for: date)
        self.service.getAvailableProfessors(for: self.reservation, inDay: date) { [weak self] (result) in
            self?.handleResult(result) {
                var professors = [Date:[Professor]]()
                for professor in $0 {
                    for reservation in professor.reservations ?? [] {
                        var items = professors[reservation.date] ?? []
                        items.append(professor)
                        professors[reservation.date] = items
                    }
                }
                
                self?.sections = professors.sorted(by: {$0.key <= $1.key}).map {
                    let date = $0.key
                    let name = formatter.string(from: date)
                    return Section(name: name, date: date, items: $0.value)
                }
            }
        }

    }
    
    struct Section: Equatable {var name: String
        var date: Date
        var items: [Professor]
        
        static func == (lhs: ScheduleProfesorViewController.Section, rhs: ScheduleProfesorViewController.Section) -> Bool {
            return lhs.date == rhs.date
        }
    }
}

extension ScheduleProfesorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.selectedSection == nil ? 1 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = self.sections else { return 0 }
        guard let index = self.selectedSection else { return sections.count }
        switch section {
        case 0:
            return index
        case 1:
            return sections[index].items.count + 1
        default:
            return sections.count - 1 - index
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sections = self.sections else { return UICollectionViewCell() }
        if indexPath.section == 1 && indexPath.row > 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "professorCell", for: indexPath) as! ProfessorCell
            guard let index = self.selectedSection else { return cell }
            let professor = sections[index].items[indexPath.row - 1]
            if let iconURL = professor.avatarUrl {
                let filter: ImageFilter = ScaledToSizeFilter(size: cell.avatarImageView.frame.size)
                cell.avatarImageView.af_setImage(withURL: iconURL, filter: filter)
            } else {
                cell.avatarImageView.image = UIImage(named: "profesor")
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
            switch indexPath.section {
            case 1:
                cell.textLabel.text = sections[self.selectedSection!].name
                cell.textLabel.backgroundColor = self.collapsedColor
            case 2:
                cell.textLabel.text = sections[self.selectedSection! + 1 + indexPath.row].name
                cell.textLabel.backgroundColor = self.collapsedColor
            default:
                cell.textLabel.text = sections[indexPath.row].name
                cell.textLabel.backgroundColor = self.collapsedColor
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sections = self.sections else { return }
        switch indexPath.section {
        case 1:
            guard indexPath.row > 0 else { return }
            self.selectedProfessor = sections[self.selectedSection!].items[indexPath.row]
        case 2:
            self.selectedSection = self.selectedSection! + 1 + indexPath.row
            self.selectedProfessor = nil
        default:
            self.selectedSection = indexPath.row
            self.selectedProfessor = nil
        }
    }
}

class ScheduleLayout: UICollectionViewLayout {
    let sectionHeaderHeight: CGFloat = 50
    let sectionHeaderPadding: CGSize = CGSize(width: 0, height: 0)
    let itemSize: CGSize = CGSize(width: 50, height: 50)
    let itemPadding: CGSize = CGSize(width: 5, height: 5)
    
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
        let itemHeight = itemPadding.height * 2
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let height = sectionHeaderPadding.height * 2 + sectionHeaderHeight
            let frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: height)
            let insetFrame = frame.insetBy(dx: sectionHeaderPadding.width, dy: sectionHeaderPadding.height)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache[indexPath] = attributes
            
            yOffset += height
        }
        
        guard collectionView.numberOfSections > 1 else {
            return self.contentHeight = yOffset
        }
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 1) {
            
            let indexPath = IndexPath(item: item, section: 1)
            
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
        
        if xOffset > 0 {
            xOffset = 0
            yOffset += itemHeight
        }
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 2) {
            
            let indexPath = IndexPath(item: item, section: 2)
            
            let height = sectionHeaderPadding.height * 2 + sectionHeaderHeight
            let frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: height)
            let insetFrame = frame.insetBy(dx: sectionHeaderPadding.width, dy: sectionHeaderPadding.height)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache[indexPath] = attributes
            
            yOffset += height
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

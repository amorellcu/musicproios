//
//  LocationListViewController.swift
//  musicprof
//
//  Created by John Doe on 7/16/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class LocationListViewController: BaseNestedViewController, ProfessorRegistrationController, ProfileSection {
    weak var updater: ProfileUpdateViewController?
    var professor: Professor!
    
    var sectionTitles: [String]?
    var locations: [String:[Location]]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.sectionIndexColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateLocations()
    }
    
    func updateLocations() {
        guard let municipalityId = self.professor.municipalityId else {
            return self.setLocations([])
        }
        self.service.getLocations(cityId: municipalityId) { [weak self] (result) in
            self?.handleResult(result) { values in
                self?.setLocations(values)
            }
        }
    }
    
    func setLocations(_ values: [Location]) {
        let locations = values.sorted(by: {$0.description <= $1.description})
        let sections = Dictionary(grouping: locations, by: {$0.description.prefix(1).uppercased()})
        self.sectionTitles = sections.keys.sorted(by: {$0 <= $1})
        self.locations = sections
        guard let professorLocations = self.professor.locations else { return }
        self.tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        for (section, title) in sectionTitles!.enumerated() {
            for (row, location) in (sections[title] ?? []).enumerated() {
                guard professorLocations.contains(location) else { continue }
                let indexPath = IndexPath(row: row, section: section)
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
}

extension LocationListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionTitle = self.sectionTitles?[section] else { return 1 }
        return self.locations?[sectionTitle]?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionTitle = self.sectionTitles?[indexPath.section], let location = self.locations?[sectionTitle]?[indexPath.row] else {
            return tableView.dequeueReusableCell(withIdentifier: "loadingCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        cell.textLabel?.text = location.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return locations == nil ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionTitle = self.sectionTitles?[indexPath.section], let location = self.locations?[sectionTitle]?[indexPath.row] else { return }
        self.professor.locations?.append(location)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let sectionTitle = self.sectionTitles?[indexPath.section], let location = self.locations?[sectionTitle]?[indexPath.row] else { return }
        self.professor.locations?.removeAll(where: {$0.id == location.id})
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitles
    }
}

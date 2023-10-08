//
//  JoinViewController.swift
//  BluetoothSampleApp
//
//  Created by kotomi takahashi on 2023/10/07.
//

import UIKit

struct Sections {
    static let name = 0
    static let availableDevices = 1
}

class JoinViewController: UITableViewController {
    static let deviceCellIdentifier = "DeviceCell"
    static let nameCellIdentifier = "NameCell"
    
    // MARK: - Class Creation -
    init() {
        super.init(style: .insetGrouped)
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(DeviceTableViewCell.self,
                           forCellReuseIdentifier: JoinViewController.deviceCellIdentifier)
        tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil),
                           forCellReuseIdentifier: JoinViewController.nameCellIdentifier)
    }
    override func viewDidAppear(_ animated: Bool) {
        // If we're in a navigation controller, hide the bar
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Sections.name { return 1 }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Sections.name {
            let cell = tableView.dequeueReusableCell(withIdentifier: JoinViewController.nameCellIdentifier,
                                                     for: indexPath)
            if let nameCell = cell as? TextFieldTableViewCell {
                // Configure callbacks
            }
            return cell
        }
        // セルは再利用する
        let cell = tableView.dequeueReusableCell(withIdentifier: JoinViewController.deviceCellIdentifier,
                                                 for: indexPath)
        if let deviceCell = cell as? DeviceTableViewCell {
            deviceCell.configureForNoDevicesFound()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Sections.availableDevices { return "Devices" }
        return nil
    }
}

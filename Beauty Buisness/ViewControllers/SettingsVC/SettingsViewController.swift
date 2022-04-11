//
//  SettingsViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 29.03.2022.
//

import Foundation
import UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    
    private let settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .myBackgroundColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView () {
        view.addSubview(settingsTableView)
        settingsTableView.frame = view.bounds
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    
    private func setupNavigationBar () {
        title = "Настройки"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        var config = cell.defaultContentConfiguration()
        
        if indexPath.row == 0 {
            config.text = "Часы работы"
        } else if indexPath.row == 1 {
            config.text = "Перечень услуг"
        }
        cell.contentConfiguration = config
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            navigationController?.pushViewController(TimeChangeOption(), animated: true)
        } else if indexPath.row == 1 {
            SalonTypesDB.shared.fetchSalonTypes()
            let salon = SalonTypesDB.shared.salonTypes.first { $0.type == UserDefaults.standard.string(forKey: "SALON-TYPE") }
            let newProcedureVC = UIHostingController(rootView: ProcedureTypesChooseView(salonType: salon!, salonTypesDB: SalonTypesDB.shared, setupProcessFinished: true))
            newProcedureVC.title = "Перечень услуг"
            navigationController?.pushViewController(newProcedureVC, animated: true)
        }
    }
    
}

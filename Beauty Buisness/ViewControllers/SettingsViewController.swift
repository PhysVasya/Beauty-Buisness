//
//  SettingsViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 29.03.2022.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    var newStartingHour: Date?
    var newEndingHour: Date?
    
    private let settingsTableView: UITableView = {
       let tv = UITableView()
        tv.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        return tv
    }()
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .myBackgroundColor
        setupTableView()
        setupNavigationBar()
    }
    
    
    private func setupTableView () {
        view.addSubview(settingsTableView)
        settingsTableView.backgroundColor = .myBackgroundColor
        settingsTableView.frame = view.bounds
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveChanges))
    }
    
    @objc private func saveChanges () {
        
        //LOGIC NEEDS TO BE CHANGED LATER!
        if let newStartingHour = newStartingHour {
            UserDefaults.standard.set(newStartingHour, forKey: "STARTING-HOUR")

        }
         
        if let newEndingHour = newEndingHour {
            UserDefaults.standard.set(newEndingHour, forKey: "ENDING-HOUR")
        }
        
    }
    
    
    //PRIVATIZED methods can only be accessed from here, pay attention to the "sender" attribute which is needed to access values from Selector
    @objc private func topTimePickerChangedValue (sender: UIDatePicker) {
             
        newStartingHour = sender.date
        
        print(newStartingHour)
        
    }
    
    @objc private func bottomTimePickerChangedValue (sender: UIDatePicker) {
           
        newEndingHour = sender.date
        
        print(newEndingHour)
       

        
        
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
            cell.backgroundColor = .myBackgroundColor
            cell.topTimePickerValueChanged(self, action: #selector(topTimePickerChangedValue(sender:)))
            cell.bottomTimePickerValueChanged(self, action: #selector(bottomTimePickerChangedValue(sender:)))
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        } else {
            return 44
        }
    }
    
}

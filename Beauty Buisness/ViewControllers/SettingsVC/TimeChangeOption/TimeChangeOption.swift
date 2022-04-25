//
//  TimeChangeOption.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation
import UIKit

class TimeChangeOption: UIViewController {
    
    private var newStartingHour: Int?
    private var newEndingHour: Int?
    private var newStartingMinute: Int?
    private var newEndingMinute: Int?
    
    private var timeHasChanged: Bool = false {
        didSet {
            setupNavigationBar()
        }
    }
    
    private let calendar = Calendar.current

    private let settingsTableView: UITableView = {
        let tv = UITableView()
        tv.register(TimeChangeOptionCell.self, forCellReuseIdentifier: TimeChangeOptionCell.identifier)
        return tv
    }()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Время работы"
        navigationController?.navigationBar.prefersLargeTitles = true
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
        let saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveChanges))
        saveButton.isEnabled = timeHasChanged
        navigationItem.rightBarButtonItem = saveButton
        
    }
    
    @objc private func saveChanges () {
        
        //LOGIC NEEDS TO BE CHANGED LATER!
        if let newStartingHour = newStartingHour,
           let newStartingMinute = newEndingMinute {
            UserDefaults.setNewStartingTime(hour: newStartingHour, minute: newStartingMinute)
        }
        
        if let newEndingHour = newEndingHour,
           let newEndingMinute = newEndingMinute {
            UserDefaults.setNewEndingTime(hour: newEndingHour, minute: newEndingMinute)
        }
    }
    
    
    //PRIVATIZED methods can only be accessed from here, pay attention to the "sender" attribute which is needed to access values from Selector
    @objc private func topTimePickerChangedValue (_ sender: UIDatePicker) {
        
        let newStartingTime = calendar.dateComponents([.hour, .minute], from: sender.date)
        newStartingHour = newStartingTime.hour
        newStartingMinute = newStartingTime.minute
        timeHasChanged = true
    }
    
    @objc private func bottomTimePickerChangedValue (_ sender: UIDatePicker) {
        
        let newEndingTime = calendar.dateComponents([.hour, .minute], from: sender.date)
        newEndingHour = newEndingTime.hour
        newEndingMinute = newEndingTime.minute
        timeHasChanged = true
    }
}

extension TimeChangeOption: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TimeChangeOptionCell.identifier, for: indexPath) as! TimeChangeOptionCell
            cell.backgroundColor = .myBackgroundColor
            cell.topTimePickerValueChanged(self, action: #selector(topTimePickerChangedValue(_:)))
            cell.bottomTimePickerValueChanged(self, action: #selector(bottomTimePickerChangedValue(_:)))
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

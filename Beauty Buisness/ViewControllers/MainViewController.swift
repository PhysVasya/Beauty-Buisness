//
//  MainViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 27.03.2022.
//

import Foundation
import UIKit


class MainViewController: UIViewController {
    
    var workingDay: WorkingDay?
    
    private let mainScreenTableView: UITableView = {
        let tv = UITableView()
        tv.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.cellIdentifier)
        tv.backgroundColor = .myBackgroundColor
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .myBackgroundColor
        navigationItem.title = UserDefaults.standard.string(forKey: "SALON-NAME")
        
        setupTableView()
        addNavBarSettingsItem()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Each time the view appears (i.e. ater changing settings also, the next methods are called to reload tableView
        workingDay = MainTableViewCell.generateHoursInWorkingDay()
        mainScreenTableView.reloadData()
    }
    
    private func setupTableView () {
        mainScreenTableView.dataSource = self
        mainScreenTableView.delegate = self
        view.addSubview(mainScreenTableView)
        mainScreenTableView.frame = view.bounds
    }
    
    
    
    
    private func addNavBarSettingsItem () {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(showSettingsViewController))
    }
    
    //Method tor gearshape button
    @objc private func showSettingsViewController () {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.cellIdentifier, for: indexPath) as! MainTableViewCell
        cell.backgroundColor = .myBackgroundColor
        var config = cell.defaultContentConfiguration()
        
        //CAREFUL force unwrap! But should always not be nil. Here we access the starting hour and depending on the number of rows, just add 1 hour each new row.
        config.text = String(workingDay!.startingHour + indexPath.row)
        
        //Just a blank.
        config.secondaryText = "TEXT"
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        //CAREFUL! 
        return workingDay!.hours.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM"
        let formattedDate = formatter.string(from: date)
        let dateLabel = UILabel()
        dateLabel.backgroundColor = .myBackgroundColor
        dateLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        dateLabel.text = formattedDate.capitalized
        dateLabel.font = .systemFont(ofSize: 24, weight: .bold)
        dateLabel.textColor = .label
        dateLabel.textAlignment = .center
        
        return dateLabel
    
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    
    
}

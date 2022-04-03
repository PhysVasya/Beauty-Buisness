//
//  MainViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 27.03.2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine


class MainViewController: UIViewController {
    
    private var newProcedureButtonTapped: (() -> Void)?
    private var model = ObservableElementsForNewProcedureButton()
    private var workingDay: WorkingDay?
    private var events: [Event] = []
    
    private let mainScreenTableView: UITableView = {
        let tv = UITableView()
        tv.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.cellIdentifier)
        tv.backgroundColor = .myBackgroundColor
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
        newProcedureButtonTapped = { [weak self] in
            let newEventVC = NewEventViewController()
            self?.navigationController?.present(UINavigationController(rootViewController: newEventVC), animated: true)
            
            newEventVC.onCompletion = { event in
                print(event!)
                
            }
            
        }
        
        view.backgroundColor = .myBackgroundColor
        navigationItem.title = UserDefaults.standard.string(forKey: "SALON-NAME")
        
        setupTableView()
        addNavBarSettingsItem()
        setupAddNewProcedureButton()
      
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        //Each time the view appears (i.e. after changing settings also, the next methods are called to reload tableView
        do {
            workingDay = try WorkingDay.generateHoursInWorkingDay()
        } catch {
            print(error)
        }
        setupBGView()
        mainScreenTableView.reloadData()
    }
    
    private func setupTableView () {
        mainScreenTableView.dataSource = self
        mainScreenTableView.delegate = self
        view.addSubview(mainScreenTableView)
        mainScreenTableView.frame = view.bounds
    }
    
    private func setupAddNewProcedureButton () {
        model.events = events.count
        let newButton = UIHostingController(rootView: NewProcedureButton(elements: model, tap: newProcedureButtonTapped)).view!
        view.addSubview(newButton)
        newButton.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        newButton.backgroundColor = .clear
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 8).isActive = true
        newButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupBGView () {
        if events.count == 0 {
            let noEventsLabel = UILabel()
            noEventsLabel.text = "Пока нет записи..."
            noEventsLabel.font = .systemFont(ofSize: 24, weight: .bold)
            noEventsLabel.textColor = .systemGray4
            noEventsLabel.textAlignment = .center
            noEventsLabel.frame = view.bounds
            noEventsLabel.restorationIdentifier = "NoEvents"
            view.addSubview(noEventsLabel)
        } else {
            let subviews = view.subviews
            if let noEventsView = subviews.first(where: {$0.restorationIdentifier == "NoEvents"}) {
                if subviews.contains(noEventsView) {
                    noEventsView.removeFromSuperview()
                }
            }
            return
        }
    }
    
    
    
    private func addNavBarSettingsItem () {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(showSettingsViewController))
    }
    
    //Method for gearshape button
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
        return events.count
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
        dateLabel.backgroundColor = .myHighlightColor
        
        return dateLabel
    
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        model.offset = scrollView.contentOffset.y
    }
    
    
    
    
}


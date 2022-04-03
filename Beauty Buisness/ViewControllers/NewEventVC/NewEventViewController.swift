//
//  NewEventViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 03.04.2022.
//

import Foundation
import UIKit

class NewEventViewController: UIViewController {
    
    
    private let newEventTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .myBackgroundColor
        tableView.register(NewEventTableViewCell.self, forCellReuseIdentifier: NewEventTableViewCell.identifier)
        return tableView
    }()
    
    private let calendar = Calendar.current
    
    private var newEvent: Event?
    //onCompletion sends data to the HomeVC as an Event type.
    public var onCompletion: ((Event?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupCancelBarButton()
        setupDoneBarButton()
    }
    
    
    private func setupTableView() {
        newEventTableView.frame = view.bounds
        view.addSubview(newEventTableView)
        newEventTableView.delegate = self
        newEventTableView.dataSource = self
        
    }
    
    private func setupCancelBarButton() {
        let cancelBarButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelBarButtonPressed))
        navigationItem.leftBarButtonItem = cancelBarButton
        
    }
    
    private func setupDoneBarButton() {
        let doneBarButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneBarButtonPressed))
        navigationItem.rightBarButtonItem = doneBarButton
    }
    
    @objc private func cancelBarButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc private func doneBarButtonPressed() {
        onCompletion?(newEvent)
        dismiss(animated: true)
    }
    
    @objc private func showDate (_ sender: UIDatePicker) {
        print(sender.date)
    }
    
    
}

extension NewEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NewEventTableViewCell.identifier, for: indexPath) as! NewEventTableViewCell
        guard let views = configureFirstTableSection(for: indexPath) else {
            return UITableViewCell()
        }
        cell.configure(with: views[0], secondView: views[1])
        
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
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Время записи"
        }
        return nil
    }
    
}

extension NewEventViewController {
    
    
    private func configureFirstTableSection (for indexPath: IndexPath) -> [UIView]? {
        
        let startingHour = Int.startingHour
        let startingMinute = Int.startingMinute
        let endingHour = Int.endingHour
        let endingMinute = Int.endingMinute
        
        let secondView = UIDatePicker()
        secondView.datePickerMode = .time
        secondView.minuteInterval = 15
        secondView.minimumDate = calendar.date(bySettingHour: startingHour, minute: startingMinute, second: 0, of: Date.now)
        secondView.maximumDate = calendar.date(bySettingHour: endingHour, minute: endingMinute, second: 0, of: Date.now)
        
        if indexPath == IndexPath(row: 0, section: 0) {
            let firstView = UILabel()
            firstView.text = "Начало процедуры"
            firstView.font = .systemFont(ofSize: 14)
            secondView.date = Date.now
            secondView.addTarget(self, action: #selector(showDate(_:)), for: .valueChanged)
            return [firstView, secondView]
        } else if indexPath == IndexPath(row: 1, section: 0) {
            let firstView = UILabel()
            firstView.text = "Конец процедуры"
            firstView.font = .systemFont(ofSize: 14)
            secondView.addTarget(self, action: #selector(showDate(_:)), for: .valueChanged)
            return [firstView, secondView]

        } else {
            return nil
        }
        
    }
    
    
    
}

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
        tableView.allowsSelection = false
        tableView.register(NewEventTableViewCell.self, forCellReuseIdentifier: NewEventTableViewCell.identifier)
        return tableView
    }()
    
    private let calendar = Calendar.current
    
    private var chosenStartHour: Int?
    private var chosenEndHour: Int?
    private var chosenStartMinute: Int?
    private var chosenEndMinute: Int?
    
    private var chosenProcedure: String?
    private var chosenClient: Customer?
    private var chosenMaster: Master?
    
    private var newEvent: Event?
    //onCompletion sends data to the HomeVC as an Event type.
    public var onCompletion: ((Event?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая запись"
        
        setupTableView()
        setupCancelBarButton()
        setupDoneBarButton()
    }
    
    
    private func setupTableView() {
        view.addSubview(newEventTableView)
        newEventTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newEventTableView.topAnchor.constraint(equalTo: view.topAnchor),
            newEventTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newEventTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newEventTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
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
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func doneBarButtonPressed() {
        
        guard let chosenStartHour = chosenStartHour,
              let chosenStartMinute = chosenStartMinute,
              let chosenEndHour = chosenEndHour,
              let chosenEndMinute = chosenEndMinute,
              let chosenProcedure = chosenProcedure,
              let chosenClient = chosenClient,
        let chosenMaster = chosenMaster else {
            return
        }
        
        newEvent = Event(context: FetchingManager.shared.managedObjectContext)
        
        onCompletion?(newEvent)
        dismiss(animated: true)
    }
    
    @objc private func eventStartTime (_ sender: UIDatePicker) {
        
        chosenStartHour = sender.hour
        chosenStartMinute = sender.minute
                        
    }
    
    @objc private func eventEndTime (_ sender: UIDatePicker) {
        
        chosenEndHour = sender.hour
        chosenEndMinute = sender.minute
            
    }
    
    @objc private func addButtonPressed(_ sender: UIButton) {
        
    }
    
    
}

extension NewEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NewEventTableViewCell.identifier, for: indexPath) as! NewEventTableViewCell
        let textField = UITextField()
        textField.delegate = self
        
        if indexPath.section == 0 {
            if let views = configureFirstTableSection(for: indexPath) {
                cell.configure(with: views[0], secondView: views[1])
            }
            return cell
        } else if indexPath.section == 1 {
            textField.placeholder = "Укажите услугу..."
            textField.tag = 0
            cell.configure(with: textField)
            return cell
        } else if indexPath.section == 2 {
            textField.placeholder = "Выберите клиента..."
            textField.tag = 1
            cell.configure(with: textField)
            return cell
        } else {
            textField.placeholder = "Выберите мастера..."
            textField.tag = 2
            cell.configure(with: textField)
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        if section == 1 {
            return 1
        }
        if section == 2 {
            return 1
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Время записи"
        } else if section == 1 {
            return "Процедура"
        } else if section == 2 {
            return "Клиент"
        } else {
            return "Мастер"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    
}

extension NewEventViewController {
    
    
    private func configureFirstTableSection (for indexPath: IndexPath) -> [UIView]? {
      
        let endingHour = Int.endingHour
        let endingMinute = Int.endingMinute
        
        let secondView = UIDatePicker()
        secondView.datePickerMode = .time
        secondView.minuteInterval = 15
        secondView.minimumDate = Date.now
        secondView.maximumDate = calendar.date(bySettingHour: endingHour, minute: endingMinute, second: 0, of: Date.now)
        
        if indexPath == IndexPath(row: 0, section: 0) {
            let firstView = UILabel()
            firstView.text = "Начало процедуры"
            firstView.font = .systemFont(ofSize: 14)
            chosenStartHour = secondView.hour
            chosenStartMinute = secondView.minute
            secondView.addTarget(self, action: #selector(eventStartTime(_:)), for: .allEvents)
            return [firstView, secondView]
        } else if indexPath == IndexPath(row: 1, section: 0) {
            let firstView = UILabel()
            firstView.text = "Конец процедуры"
            firstView.font = .systemFont(ofSize: 14)
            chosenEndHour = secondView.hour
            chosenEndMinute = secondView.minute
            secondView.date = calendar.date(bySettingHour: 1, minute: 0, second: 0, of: Date.now)!
            secondView.addTarget(self, action: #selector(eventEndTime(_:)), for: .allEvents)
            return [firstView, secondView]
            
        } else {
            return nil
        }
        
    }
    
    
    
}


extension NewEventViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 0 {
            chosenProcedure = textField.text
        } else if textField.tag == 1 {
            chosenClient = Customer()
        } else {
            chosenMaster = Master()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

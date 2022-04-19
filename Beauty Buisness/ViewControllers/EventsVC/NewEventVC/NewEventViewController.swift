//
//  NewEventViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 03.04.2022.
//

import Foundation
import UIKit
import CoreData

class NewEventViewController: UIViewController {
    
    private let newEventTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .myBackgroundColor
        tableView.register(NewEventTableCell.self, forCellReuseIdentifier: NewEventTableCell.identifier)
        return tableView
    }()
    
    public var day: Day? 
    
    private var fetchedProcedures: [Procedure]?
    private var fetchedCustomers: [Customer]?
    private var fetchedMasters: [Master]?
        
    private var chosenStartHour: Int?
    private var chosenEndHour: Int?
    private var chosenStartMinute: Int?
    private var chosenEndMinute: Int?
    
    private var chosenProcedure: Procedure?
    private var chosenClient: Customer?
    private var chosenMaster: Master?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая запись"
        
        setupTableView()
        setupCancelBarButton()
        setupDoneBarButton()
    }
    
    private func setupTableView() {
        view.addSubview(newEventTableView)
        newEventTableView.frame = view.bounds
        newEventTableView.translatesAutoresizingMaskIntoConstraints = false
        
   
        
        newEventTableView.backgroundColor = .myBackgroundColor
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
              let chosenMaster = chosenMaster,
              let chosenDay = day else {
            return
        }
        
        EventsFetchingManager.shared.saveEvent(chosenStartHour, chosenStartMinute, chosenEndHour, chosenEndMinute, chosenDay, chosenProcedure, chosenClient, chosenMaster)
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NewEventTableCell.identifier, for: indexPath) as! NewEventTableCell
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.addTarget(self, action: #selector(onTextChanged(_:)), for: .editingChanged)
        
        if indexPath.section == 0 {
            if let views = configureFirstTableSection(for: indexPath) {
                cell.configure(with: views[0], secondView: views[1])
            }
            return cell
            
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                textField.placeholder = "Укажите услугу..."
                textField.tag = indexPath.section
                cell.configure(with: textField)
                return cell
            } else {
                let label = UILabel()
                label.text = fetchedProcedures?[indexPath.row - 1].name
                cell.configure(with: label)
                return cell
            }
            
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                textField.placeholder = "Выберите клиента..."
                textField.tag = indexPath.section
                cell.configure(with: textField)
                return cell
            } else {
                let label = UILabel()
                label.text = fetchedCustomers?[indexPath.row - 1].name
                cell.configure(with: label)
                return cell
            }
            
        } else {
            if indexPath.row == 0 {
                textField.placeholder = "Выберите мастера..."
                textField.tag = indexPath.section
                cell.configure(with: textField)
                return cell
            } else {
                let label = UILabel()
                label.text = fetchedMasters?[indexPath.row - 1].name
                cell.configure(with: label)
                return cell
            }
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
            return fetchedProcedures?.count != nil ? fetchedProcedures!.count + 1 : 1
        }
        if section == 2 {
            return fetchedCustomers?.count != nil ? fetchedCustomers!.count + 1 : 1
        } else {
            return fetchedMasters?.count != nil ? fetchedMasters!.count + 1 : 1
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row > 0 {
            self.chosenProcedure = fetchedProcedures?[indexPath.row - 1]
            fetchedProcedures = nil
            if let indexPaths = tableView.indexPathsForVisibleRows?.compactMap({ $0.section == indexPath.section && $0.row != 0 ? $0 : nil }) {
                tableView.beginUpdates()
                tableView.deleteRows(at: indexPaths, with: .automatic)
                tableView.endUpdates()
                tableView.endEditing(true)
            }
        }
        
        if indexPath.section == 2 && indexPath.row > 0 {
            self.chosenClient = fetchedCustomers?[indexPath.row - 1]
            fetchedCustomers = nil
            if let indexPaths = tableView.indexPathsForVisibleRows?.compactMap({ $0.section == indexPath.section && $0.row != 0 ? $0 : nil }) {
                tableView.beginUpdates()
                tableView.deleteRows(at: indexPaths, with: .automatic)
                tableView.endUpdates()
                tableView.endEditing(true)
            }
        }
        
        if indexPath.section == 3 && indexPath.row > 0 {
            self.chosenMaster = fetchedMasters?[indexPath.row - 1]
            fetchedMasters = nil
            if let indexPaths = tableView.indexPathsForVisibleRows?.compactMap({ $0.section == indexPath.section && $0.row != 0 ? $0 : nil }) {
                tableView.beginUpdates()
                tableView.deleteRows(at: indexPaths, with: .automatic)
                tableView.endUpdates()
                tableView.endEditing(true)
            }
        }
        
        
    }
    
}

extension NewEventViewController {
    
    
    private func configureFirstTableSection (for indexPath: IndexPath) -> [UIView]? {
        
        let endingHour = Int.endingHour
        let endingMinute = Int.endingMinute
        let startingHour = Int.startingHour
        let startingMinute = Int.startingMinute
     
        guard let currentDay = day?.getDate() else { return nil }
        
        let startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .time
        startDatePicker.minuteInterval = 5
        startDatePicker.setDate(currentDay, animated: false)
        startDatePicker.minimumDate = Calendar.current.date(bySettingHour: startingHour, minute: startingMinute, second: 0, of: currentDay)
        startDatePicker.maximumDate = Calendar.current.date(bySettingHour: endingHour, minute: endingMinute, second: 0, of: currentDay)
        
        let endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .time
        endDatePicker.minuteInterval = 5
        endDatePicker.setDate(currentDay + 100, animated: false)
        endDatePicker.minimumDate = Calendar.current.date(bySettingHour: startingHour, minute: startingMinute, second: 0, of: currentDay)
        endDatePicker.maximumDate = Calendar.current.date(bySettingHour: endingHour, minute: endingMinute, second: 0, of: currentDay)
        
        if indexPath == IndexPath(row: 0, section: 0) {
            let firstView = UILabel()
            firstView.text = "Начало процедуры"
            firstView.font = .systemFont(ofSize: 16)
            chosenStartHour = startDatePicker.hour
            chosenStartMinute = startDatePicker.minute
            startDatePicker.addTarget(self, action: #selector(eventStartTime(_:)), for: .allEvents)
            return [firstView, startDatePicker]
        } else if indexPath == IndexPath(row: 1, section: 0) {
            let firstView = UILabel()
            firstView.text = "Конец процедуры"
            firstView.font = .systemFont(ofSize: 16)
            chosenEndHour = startDatePicker.hour
            chosenEndMinute = startDatePicker.minute
            endDatePicker.addTarget(self, action: #selector(eventEndTime(_:)), for: .allEvents)
            return [firstView, endDatePicker]
            
        } else {
            return nil
        }
        
    }
}


extension NewEventViewController: UITextFieldDelegate {
    
    private enum TextFieldSection {
        
        case firstSection(with: String?)
        case secondSection(with: String?)
        case thirdSection(with: String?)
        
        func toFinishFetching () async -> Array<NSManagedObject>? {
            
            switch self {
            case .firstSection(let input):
                return ProceduresFetchingManager.shared.fetchExistingProcedure(procedureName: input)
            case .secondSection(let input):
                return CustomersFetchingManager.shared.fetchExistingCustomer(customerName: input)
            case .thirdSection(let input):
                return MastersFetchingManager.shared.fetchExistingMaster(masterName: input)
            }
        }
    }
        
    @objc private func onTextChanged (_ sender: UITextField) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                
                if sender.tag == 1 {
                    self?.makeCoreDataSearch(using: sender.tag, on: .firstSection(with: sender.text))
                }
                if sender.tag == 2 {
                    self?.makeCoreDataSearch(using: sender.tag, on: .secondSection(with: sender.text))
                }
                if sender.tag == 3 {
                    self?.makeCoreDataSearch(using: sender.tag, on: .thirdSection(with: sender.text))
                }
            }
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            textField.text = chosenProcedure?.name
        }
        if textField.tag == 2 {
            textField.text = chosenClient?.name
        }
        if textField.tag == 3 {
            textField.text = chosenMaster?.name
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}


extension NewEventViewController {
    
    private func makeCoreDataSearch (using senderTag: Int, on sectionNumber: TextFieldSection) {
        
        Task {
            if let fetchResults = await sectionNumber.toFinishFetching() {
                
                if !fetchResults.isEmpty {
                    fetchedProcedures = fetchResults as? [Procedure]
                    fetchedCustomers = fetchResults as? [Customer]
                    fetchedMasters = fetchResults as? [Master]
                    
                    let indexPaths = fetchResults.map { procedure -> IndexPath in
                        return IndexPath(row: fetchResults.firstIndex(of: procedure)! + 1, section: senderTag)
                    }
                    if indexPaths.count + 1 > self.newEventTableView.numberOfRows(inSection: senderTag) {
                        newEventTableView.beginUpdates()
                        newEventTableView.insertRows(at: indexPaths, with: .automatic)
                        newEventTableView.endUpdates()
                    } else if indexPaths.count + 1 < self.newEventTableView.numberOfRows(inSection: senderTag) {
                        newEventTableView.beginUpdates()
                        newEventTableView.deleteRows(at: indexPaths, with: .automatic)
                        newEventTableView.endUpdates()
                    }
                } else {
                    fetchedProcedures = nil
                    if let indexPaths = self.newEventTableView.indexPathsForVisibleRows?.compactMap({$0.section == senderTag && $0.row != 0 ? $0 : nil}) {
                        newEventTableView.beginUpdates()
                        newEventTableView.deleteRows(at: indexPaths, with: .automatic)
                        newEventTableView.endUpdates()
                    }
                }
            }
        }
        
    }
}





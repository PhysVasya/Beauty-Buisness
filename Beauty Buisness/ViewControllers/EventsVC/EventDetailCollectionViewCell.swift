//
//  EventDetailCollectionViewCell.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 21.04.2022.
//

import Foundation
import UIKit
import Combine

class EventDetailCollectionViewCell: UICollectionViewCell {
        
    private let procedurePickerView = UIPickerView()
    private let masterPickerView = UIPickerView()
    private let customerPickerView = UIPickerView()

    private let procedures = ProceduresFetchingManager.shared.fetchProcedures()
    private let masters = MastersFetchingManager.shared.fetchMasters()
    private let customers = CustomersFetchingManager.shared.fetchCustomers()
    
    private var indexOfEventProcedure: Int?
    private var indexOfEventMaster: Int?
    private var indexOfEventCustomer: Int?
    
    private var procedureChanged: Procedure?
    private var masterChanged: Master?
    private var customerChanged: Customer?
    
    private var editingEvent: Event?
    
    private var isEditing: Bool? {
        didSet {
            saveChanges()
        }
    }
 
    public func configure (event: Event?) {
        
        guard let event = event,
              let eventName = event.procedure?.name,
              let nameView = configureNameLabel(with: eventName),
              let masterView = configureMasterLabel(with: event.master?.name),
              let customerView = configureCustomerLabel(with: event.customer?.name),
              let eventView = configureEventLabel(with: event)  else { return }
        configureCellLayout(views: [
            eventView,
            nameView,
            masterView,
            customerView
        ])
        guard let eventProcedure = event.procedure,
              let eventMaster = event.master,
              let eventCustomer = event.customer else { return }
        indexOfEventProcedure = procedures?.firstIndex(of: eventProcedure)
        indexOfEventMaster = masters?.firstIndex(of: eventMaster)
        indexOfEventCustomer = customers?.firstIndex(of: eventCustomer)
        editingEvent = event
        
    }
    
    private func configureEventLabel (with event: Event?) -> UIView? {
        guard let event = event else { return nil }
        let selectedEventTime = "Запись с \(event.startHour):\(event.startMinute) до \(event.endHour):\(event.endMinute)"
        let eventTimeLabel = UILabel()
        eventTimeLabel.text = selectedEventTime
        eventTimeLabel.font = .boldSystemFont(ofSize: 24)
        eventTimeLabel.textColor = .myBackgroundColor
        eventTimeLabel.textAlignment = .center
        
        return eventTimeLabel
    }
    
    private func configureNameLabel (with text: String?) -> UIView? {
        
        let propLabel = UILabel()
        propLabel.text = "Процедура"
        propLabel.font = .boldSystemFont(ofSize: 18)
        propLabel.textColor = .myBackgroundColor
        procedurePickerView.tag = 0
        procedurePickerView.dataSource = self
        procedurePickerView.delegate = self
        procedurePickerView.isUserInteractionEnabled = false
        
        let hStack = UIStackView(arrangedSubviews: [
            propLabel,
            procedurePickerView
        ])
        hStack.distribution = .fillEqually
        
        return hStack
        
    }
    
    private func configureMasterLabel (with masterName: String?) -> UIView? {
        
        let propLabel = UILabel()
        propLabel.text = "Мастер"
        propLabel.font = .boldSystemFont(ofSize: 18)
        propLabel.textColor = .myBackgroundColor
        masterPickerView.tag = 1
        masterPickerView.dataSource = self
        masterPickerView.delegate = self
        masterPickerView.isUserInteractionEnabled = false
      

        
        let hStack = UIStackView(arrangedSubviews: [
            propLabel,
            masterPickerView
        ])
        hStack.distribution = .fillEqually
        
        return hStack
    }
    
    private func configureCustomerLabel (with customerName: String?) -> UIView? {
        
        let propLabel = UILabel()
        propLabel.text = "Клиент"
        propLabel.font = .boldSystemFont(ofSize: 18)
        propLabel.textColor = .myBackgroundColor
        customerPickerView.tag = 3
        customerPickerView.dataSource = self
        customerPickerView.delegate = self
        customerPickerView.isUserInteractionEnabled = false
        
        let hStack = UIStackView(arrangedSubviews: [
            propLabel,
            customerPickerView
        ])
        hStack.distribution = .fillEqually
        
        return hStack
    }
    
    private func configureCellLayout (views: [UIView]) {
        
        
        //VerticalStack global
        let verticalStack = UIStackView(arrangedSubviews: views)
        
        contentView.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  40)
        ])
        verticalStack.axis = .vertical
        verticalStack.spacing = 20
        verticalStack.distribution = .fillEqually


    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .myAccentColor
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "editButtonPressed"), object: nil, queue: .current) { [weak self] object in
            switch object.object as! Bool {
            case true:
                self?.procedurePickerView.isUserInteractionEnabled = true
                self?.masterPickerView.isUserInteractionEnabled = true
                self?.customerPickerView.isUserInteractionEnabled = true
                self?.isEditing = true

            case false:
                self?.procedurePickerView.isUserInteractionEnabled = false
                self?.masterPickerView.isUserInteractionEnabled = false
                self?.customerPickerView.isUserInteractionEnabled = false
                self?.isEditing = false
                
            }
        }
     
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        procedurePickerView.selectRow(indexOfEventProcedure!, inComponent: 0, animated: false)
        masterPickerView.selectRow(indexOfEventMaster!, inComponent: 0, animated: false)
        customerPickerView.selectRow(indexOfEventCustomer!, inComponent: 0, animated: false)


    }
    
    private func saveChanges () {
        guard let isEditing = isEditing,
              let editingEvent = editingEvent else { return }

        if !isEditing {
            if procedureChanged != nil {
                editingEvent.procedure = procedureChanged
                EventsFetchingManager.shared.updateEvent(editingEvent)
            }
            if masterChanged != nil {
                editingEvent.master = masterChanged
                EventsFetchingManager.shared.updateEvent(editingEvent)
            }
            if customerChanged != nil {
                editingEvent.customer = customerChanged
                EventsFetchingManager.shared.updateEvent(editingEvent)
            }
        }
    }

    
}

extension EventDetailCollectionViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return procedures?.count ?? 1
        } else if pickerView.tag == 1 {
            return masters?.count ?? 1
        } else {
            return customers?.count ?? 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var labelView = UILabel()
        if let view = view {
            labelView = view as! UILabel
        }
        labelView.font = .systemFont(ofSize: 18)
        labelView.textAlignment = .center
        labelView.textColor = .myBackgroundColor
        
        if pickerView.tag == 0 {
            guard let procedures = procedures else { return labelView }
            let procedureNames = procedures.compactMap({ $0.name })
            labelView.text = procedureNames[row]

            return labelView
        } else if pickerView.tag == 1 {
            guard let masters = masters else { return labelView }
            let masterNames = masters.compactMap({ $0.name })
            labelView.text = masterNames[row]

            return labelView
        } else {
           guard let customers = customers else { return labelView }
            let customerNames = customers.compactMap({ $0.name })
            labelView.text = customerNames[row]

            return labelView
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            guard let procedures = procedures else { return }
            procedureChanged = procedures[row]
            
        } else if pickerView.tag == 1 {
            guard let masters = masters else { return }
            masterChanged = masters[row]

        } else {
            guard let customers = customers else { return }
            customerChanged = customers[row]

        }
    }
    
    
    
}




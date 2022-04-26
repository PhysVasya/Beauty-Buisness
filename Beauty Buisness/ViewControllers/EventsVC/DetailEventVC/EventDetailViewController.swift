//
//  EventDetailViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 21.04.2022.
//

import Foundation
import UIKit


class EventDetailViewController: UIViewController {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<EventDetailSection, EventDetailItem>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<EventDetailSection, EventDetailItem>
    
    private let procedures = ProceduresFetchingManager.shared.fetchProcedures()
    private let masters = MastersFetchingManager.shared.fetchMasters()
    private let customers = CustomersFetchingManager.shared.fetchCustomers()
    
    private var eventDetailCollectionView: UICollectionView!
    private var eventDetailDiffableDataSource: DataSource!
    
    private var editBarButtonPressed: Bool = false {
        didSet {
            eventDetailCollectionView.isUserInteractionEnabled = editBarButtonPressed
            setupNavigationBar()
            saveChanges()
        }
    }
    
    public var events: [Event]?
    public var selectedEvent: Event?
    
    private var indexOfEventProcedure: Int?
    private var indexOfEventMaster: Int?
    private var indexOfEventCustomer: Int?
    
    private var procedureChanged: Procedure?
    private var masterChanged: Master?
    private var customerChanged: Customer?
    private var noteChanged: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .myBackgroundColor
        setupNavigationBar()
        setupEventDetailCollectionView()
        setupDataSource()
        createInitialSnapshot()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showSelectedItem()
    }
    
    public func configureDetail (event: Event, from: [Event]) {
        selectedEvent = event
        events = from
    }
    
    
    
    public func showSelectedItem () {
        
        guard let events = events,
              let selectedEvent = selectedEvent,
              let indexOfEvent = events.firstIndex(of: selectedEvent),
              let sectionToShow = eventDetailDiffableDataSource.sectionIdentifier(for: indexOfEvent),
              let indexOfSection = eventDetailDiffableDataSource.index(for: sectionToShow) else { return }
        
        eventDetailCollectionView.scrollToItem(at: IndexPath(row: 0, section: indexOfSection), at: .centeredVertically, animated: false)
        
    }
    
    //        private func updateSelectedEventOnScroll (by indexPath: IndexPath) {
    //
    //            let eventAtIndexPath = eventDetailDiffableDataSource.itemIdentifier(for: indexPath)
    //            selectedEvent = eventAtIndexPath
    //
    //        }
    
    private func setupEventDetailCollectionView () {
        
        let layout = createLayout()
        eventDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.addSubview(eventDetailCollectionView)
        eventDetailCollectionView.backgroundColor = .myBackgroundColor
        eventDetailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        eventDetailCollectionView.isPagingEnabled = true
        eventDetailCollectionView.isUserInteractionEnabled = editBarButtonPressed
        NSLayoutConstraint.activate([
            eventDetailCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            eventDetailCollectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            eventDetailCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            eventDetailCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        eventDetailCollectionView.alwaysBounceVertical = false
        eventDetailCollectionView.delegate = self
    }
    
    //MARK: - Layout
    private func createLayout () -> UICollectionViewCompositionalLayout {
        
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        // Group
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            ),
            subitem: item,
            count: 5
        )
        // Section
        let section = NSCollectionLayoutSection(group: group)
        //        section.orthogonalScrollingBehavior = .groupPaging
        //
        //
        //        MAGIC HAPPENS HERE! The visibleItemsInvalidationHandler closure is triggered EVERY FCKIN TIME the item appears on screen. I loop through each of the current visible items, then I compare the current scrollOffset to the visible item's frame origin, AND IF those are true (and the are only after the next visible item stays still on screen, the title and selected events are changed!
        //        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, scrollOffset, layoutEnvironment in
        //            visibleItems.forEach { visItem in
        //                if scrollOffset == visItem.frame.origin {
        //                    self?.updateSelectedEventOnScroll(by: visItem.indexPath)
        //                }
        //            }
        //        }
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.scrollDirection = .horizontal
        layoutConfig.interSectionSpacing = 10
        //Return
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    //MARK: - Data source
    private func setupDataSource () {
        
        let cellRegistration = UICollectionView.CellRegistration<EventDetailCell, EventDetailItem> { [weak self] cell, indexPath, item in
            
            cell.delegate = self
            
            //Seems i am stupid
            
            if indexPath == IndexPath(row: 1, section: indexPath.section) {
                guard let pickerView = self?.configurePickerView(),
                      let procedures = self?.procedures,
                      let cellItem = item.item as? Procedure,
                      let itemIndex = procedures.firstIndex(of: cellItem)  else { return }
                pickerView.tag = 0
                pickerView.selectRow(itemIndex, inComponent: 0, animated: false)
                cell.configure(with: .procedure, supplementary: pickerView)
            }
            
            if indexPath == IndexPath(row: 2, section: indexPath.section) {
                guard let pickerView = self?.configurePickerView(),
                      let customers = self?.customers,
                      let cellItem = item.item as? Customer,
                      let itemIndex = customers.firstIndex(of: cellItem)  else { return }
                pickerView.tag = 1
                pickerView.selectRow(itemIndex, inComponent: 0, animated: false)
                
                cell.configure(with: .customer, supplementary: pickerView)
            }
            
            if indexPath == IndexPath(row: 3, section: indexPath.section) {
                guard let pickerView = self?.configurePickerView(),
                      let masters = self?.masters,
                      let cellItem = item.item as? Master,
                      let itemIndex = masters.firstIndex(of: cellItem)  else { return }
                pickerView.tag = 2
                pickerView.selectRow(itemIndex, inComponent: 0, animated: false)
                cell.configure(with: .master, supplementary: pickerView)
            }
            
            if indexPath == IndexPath(row: 4, section: indexPath.section) {
                let textField = UITextField()
                textField.text = item.item as? String
                textField.textColor = .myBackgroundColor
                textField.font = .systemFont(ofSize: 16)
                textField.backgroundColor = .myBackgroundColor?.withAlphaComponent(0.15)
                textField.textAlignment = .center
                textField.layer.cornerRadius = 5
                cell.configure(with: .note, supplementary: textField)
            }
            
            if indexPath == IndexPath(row: 0, section: indexPath.section) {
                cell.configureTimeLabel(for: (self?.eventDetailDiffableDataSource.sectionIdentifier(for: indexPath.section)!)!)
            }
            
        }
        
        eventDetailDiffableDataSource = DataSource(collectionView: eventDetailCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            
        }
    }
    
    private func createInitialSnapshot () {
        
        var snapshot = SnapShot()
        guard let events = events else { return }
        let sections = events.compactMap { event -> EventDetailSection in
            let section = EventDetailSection(event: event)
            return section
        }
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            guard let event = section.event else { return }
            let item2 = EventDetailItem(item: event.procedure)
            let item3 = EventDetailItem(item: event.customer)
            let item4 = EventDetailItem(item: event.master)
            let item5 = EventDetailItem(item: event.note)
            let item1 = EventDetailItem(item: event.day)
            snapshot.appendItems([item1, item2, item3, item4, item5], toSection: section)
        }
        eventDetailDiffableDataSource.apply(snapshot)
        
    }
    
    //MARK: - NavigationBar and Picker configurations
    private func setupNavigationBar () {
        title = "Детализация"
        let editBarButton = UIBarButtonItem(title: editBarButtonPressed ? "Готово" : "Изменить", style: editBarButtonPressed ? .done : .plain, target: self, action: #selector(editAction(_:)))
        navigationItem.rightBarButtonItem = editBarButton
    }
    
    @objc private func editAction (_ sender: UIAction) {
        editBarButtonPressed = !editBarButtonPressed
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editButtonPressed"), object: editBarButtonPressed, userInfo: nil)
    }
    
    
    private func configurePickerView () -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }
    
    private func configurePickerViewDataSource (for pickerView: UIPickerView) -> [Any]? {
        if pickerView.tag == 0 {
            guard let procedures = procedures else { return nil }
            return procedures
        } else if pickerView.tag == 1 {
            guard let customers = customers else { return nil }
            return customers
        } else if pickerView.tag == 2 {
            guard let masters = masters else { return nil }
            return masters
        } else {
            return nil
        }
    }
    
    private func saveChanges () {
        guard let selectedEvent = selectedEvent else { return }
        
        if !editBarButtonPressed {
            if procedureChanged != nil {
                selectedEvent.procedure = procedureChanged
                EventsFetchingManager.shared.updateEvent(selectedEvent)
            }
            if masterChanged != nil {
                selectedEvent.master = masterChanged
                EventsFetchingManager.shared.updateEvent(selectedEvent)
            }
            if customerChanged != nil {
                selectedEvent.customer = customerChanged
                EventsFetchingManager.shared.updateEvent(selectedEvent)
            }
            if noteChanged != nil {
                selectedEvent.note = noteChanged
                EventsFetchingManager.shared.updateEvent(selectedEvent)
            }
        }
    }
    
}


extension EventDetailViewController: UICollectionViewDelegate {
    
    
    
}

//MARK: - PickerView delegates

extension EventDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource, EventDatePickerDelegate {
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            guard let procedures = procedures else { return }
            procedureChanged = procedures[row]
            
        } else if pickerView.tag == 1 {
            guard let customers = customers else { return }
            customerChanged = customers[row]
            
        } else if pickerView.tag == 2 {
            guard let masters = masters else { return }
            masterChanged = masters[row]
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let numberOfObjects = configurePickerViewDataSource(for: pickerView)?.count else { return 1 }
        return numberOfObjects
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var labelView = UILabel()
        labelView.font = .systemFont(ofSize: 16)
        labelView.textColor = .myBackgroundColor
        labelView.textAlignment = .center
        
        if let view = view {
            labelView = view as! UILabel
        }
        
        guard let object = configurePickerViewDataSource(for: pickerView) else { return labelView }
        
        if let procedures = object as? [Procedure],
           let procedureName = procedures[row].name {
            labelView.text = procedureName
            return labelView
        }
        
        if let customers = object as? [Customer],
           let customerName = customers[row].name {
            labelView.text = customerName
            return labelView
        }
        
        if let masters = object as? [Master],
           let masterName = masters[row].name {
            labelView.text = masterName
            return labelView
        }
        
        return labelView
    }
    
    func datePickerValueChanged(_ datePicker: UIDatePicker) {
        guard let selectedEvent = selectedEvent else { return }
        if datePicker.tag == 0 {
            guard let newEventStartingHour = DateComponents(hour: datePicker.hour).hour,
                  let newEventStartingMinute = DateComponents(minute: datePicker.minute).minute else { return }
            selectedEvent.startHour = Int16(newEventStartingHour)
            selectedEvent.startMinute = Int16(newEventStartingMinute)
        } else if datePicker.tag == 1 {
            guard let newEventEndingHour = DateComponents(hour: datePicker.hour).hour,
                  let newEventEndingMinute = DateComponents(minute: datePicker.minute).minute else { return }
            selectedEvent.endHour = Int16(newEventEndingHour)
            selectedEvent.endMinute = Int16(newEventEndingMinute)
        }
    }
    
}



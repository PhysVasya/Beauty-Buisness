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
import CoreData


class EventsViewController: UIViewController {
    
    private let eventsTableView: UITableView = {
        let tv = UITableView()
        tv.register(EventsTableCell.self, forCellReuseIdentifier: EventsTableCell.cellIdentifier)
        tv.backgroundColor = .myBackgroundColor
        return tv
    }()
    private let segmentedControl = UISegmentedControl()
    
    private var dateForEvents: Day? {
        didSet {
            reloadEvents { [weak self] in
                self?.updateSegmentedControl()
                self?.eventsTableView.reloadData()
            }
        }
    }
    private var selectedDayString: String? {
        if (dateForEvents?.month)! < 10 {
            return "\((dateForEvents?.day)!).0\((dateForEvents?.month)!)"
        } else {
            return "\((dateForEvents?.day)!).\((dateForEvents?.month)!)"
        }
    }

    private var newProcedureButtonTapped: (() -> Void)?
    private var newEventObservableElements = ObservableElementsForNewProcedureButton()
    private var workingDay: WorkingDay?
    
    private var fetchedEvents: NSFetchedResultsController<Event>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newProcedureButtonTapped = { [weak self] in
            let newEventVC = NewEventViewController()
            newEventVC.day = self?.dateForEvents
            if let sheet = newEventVC.sheetPresentationController {
                sheet.detents = [.large()]
            }
            self?.navigationController?.present(UINavigationController(rootViewController: newEventVC), animated: true)
            
        }
        
        navigationItem.title = UserDefaults.standard.string(forKey: "SALON-NAME")
        
        setupTableView()
        setupAddNewProcedureButton()
        setupSegmentedControl()
        setupNavigationBar()
        
    }
    
    private func reloadEvents (reload: (() -> Void)? = nil) {
        Task {
            guard let dateForEvents = dateForEvents else {
                return
            }
            fetchedEvents = await EventsFetchingManager.shared.fetchEventsForToday(dateForEvents)
            fetchedEvents?.delegate = self
            newEventObservableElements.events = fetchedEvents?.sections?[0].numberOfObjects
            reload?()
            setupBGView()
        }
        
    }
    
    private func setupSegmentedControl () {
        segmentedControl.insertSegment(withTitle: "Сегодня", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Завтра", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        dateForEvents = Date.todayAsDay()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
    }
    
    private func setupTableView () {
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        view.addSubview(eventsTableView)
        eventsTableView.frame = view.bounds
        
    }
    
    private func setupAddNewProcedureButton () {
        let newButton = UIHostingController(rootView: NewProcedureButton(name: "Новая запись", elements: newEventObservableElements, tap: newProcedureButtonTapped)).view!
        view.addSubview(newButton)
        newButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        newButton.backgroundColor = .clear
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 8).isActive = true
        newButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupBGView () {
        let subviews = view.subviews
        
        if fetchedEvents?.sections?.count == 0 || fetchedEvents?.sections == nil || fetchedEvents?.sections?[0].objects?.count == 0 {
            if let noEventsView = subviews.first(where: {$0.restorationIdentifier == "NoEvents"}) {
                if subviews.contains(noEventsView) {
                    //                    noEventsView.removeFromSuperview()
                }
            } else {
                let noEventsLabel = UILabel()
                noEventsLabel.text = "Пока нет записи..."
                noEventsLabel.font = .systemFont(ofSize: 24, weight: .bold)
                noEventsLabel.textColor = .systemGray4
                noEventsLabel.textAlignment = .center
                noEventsLabel.frame = view.bounds
                noEventsLabel.restorationIdentifier = "NoEvents"
                view.addSubview(noEventsLabel)
            }
        } else {
            if let noEventsView = subviews.first(where: {$0.restorationIdentifier == "NoEvents"}) {
                if subviews.contains(noEventsView) {
                    noEventsView.removeFromSuperview()
                }
            }
        }
    }
    
    private func setupNavigationBar () {
        let calendarPickerButton = UIBarButtonItem(image: .init(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarPickerButtonPressed(_:)))
        navigationItem.rightBarButtonItem = calendarPickerButton
    }
    
    private func updateSegmentedControl () {
        if Date.todayAsDay() != dateForEvents && Date.tomorrowAsDay() != dateForEvents {
            if segmentedControl.numberOfSegments >= 3 {
                segmentedControl.removeSegment(at: 2, animated: false)
                segmentedControl.insertSegment(withTitle: selectedDayString, at: 2, animated: false)
                segmentedControl.selectedSegmentIndex = 2

            } else {
                segmentedControl.insertSegment(withTitle: selectedDayString, at: 2, animated: true)
                segmentedControl.selectedSegmentIndex = 2
            }
        } else if Date.todayAsDay() == dateForEvents {
            segmentedControl.removeSegment(at: 2, animated: true)
            segmentedControl.selectedSegmentIndex = 0
            
        } else {
            segmentedControl.removeSegment(at: 2, animated: true)
            segmentedControl.selectedSegmentIndex = 1
        }
        
    }
    
    @objc private func segmentedControlChanged (_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            dateForEvents = Date.tomorrowAsDay()
        }
        if sender.selectedSegmentIndex == 0 {
            dateForEvents = Date.todayAsDay()
        }
    }
    
    @objc private func calendarPickerButtonPressed (_ sender: UIBarButtonItem) {
        let datePickerController = DatePickerViewController()
        datePickerController.datePickerDelegate = self
        datePickerController.showingDate = Calendar.current.date(from: DateComponents(year: dateForEvents?.year, month: dateForEvents?.month, day: dateForEvents?.day))
        datePickerController.modalPresentationStyle = .popover
        datePickerController.popoverPresentationController?.permittedArrowDirections = .up
        datePickerController.preferredContentSize = CGSize(width: 320, height: 320)
        datePickerController.popoverPresentationController?.delegate = self
        datePickerController.popoverPresentationController?.barButtonItem = sender
        
        present(datePickerController, animated: true)
        
        
    }
    
    @objc private func dateSelected (_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: sender.date)
        print(components)
    }
}


extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedEvents?.sections?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event = fetchedEvents?.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EventsTableCell.cellIdentifier, for: indexPath) as! EventsTableCell
        cell.backgroundColor = .myBackgroundColor
        var config = cell.defaultContentConfiguration()
        
        //CAREFUL force unwrap! But should always not be nil. Here we access the starting hour and depending on the number of rows, just add 1 hour each new row.
        config.text = event?.procedure?.name
        
        if let masterName = event?.master?.name,
           let clientName = event?.customer?.name,
           let eventStartHour = event?.startHour,
           let eventStartMinute = event?.startMinute,
           let eventEndHour = event?.endHour,
           let eventEndMinute = event?.endMinute {
            config.secondaryText = "У \(masterName) с \(eventStartHour):\(eventStartMinute) до \(eventEndHour):\(eventEndMinute)"
        }
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //CAREFUL!
        
        guard let sectionInfo = fetchedEvents?.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let date = dateForEvents,
              let eventDate = Calendar.current.date(from: DateComponents(year: date.year, month: date.month, day: date.day)) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM"
        let formattedDate = formatter.string(from: eventDate)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] action, view, handler in
            guard let event = self?.fetchedEvents?.object(at: indexPath) else { return }
            
            EventsFetchingManager.shared.deleteEvent(event)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .myAccentColor
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return config
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { [weak self] action, view, handler in
            guard let event = self?.fetchedEvents?.object(at: indexPath) else { return }
        }
        editAction.backgroundColor = .myHighlightColor
        editAction.image = UIImage(systemName: "pencil")
        let config = UISwipeActionsConfiguration(actions: [editAction])
        return config
    }
    
    
    
    
}

extension EventsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        eventsTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        reloadEvents()
        switch type {
        case .insert:
            eventsTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            eventsTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            eventsTableView.deleteRows(at: [indexPath!], with: .automatic)
            eventsTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            let cell = eventsTableView.cellForRow(at: indexPath!)
            let event = fetchedEvents?.object(at: indexPath!)
            var config = cell?.defaultContentConfiguration()
            config?.text = event?.procedure?.name
            cell?.contentConfiguration = config
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        eventsTableView.endUpdates()
    }
    
}

extension EventsViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newEventObservableElements.offset = scrollView.contentOffset.y
    }
}


extension EventsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension EventsViewController: UIDatePickerDelegate {
    func selectedDate(_ inPicker: UIDatePicker) {
        
        let selectedDate = Calendar.current.dateComponents([.day, .month, .year], from: inPicker.date)
        
        dateForEvents = selectedDate.workingDay
        navigationController?.dismiss(animated: true)
    }
    
}



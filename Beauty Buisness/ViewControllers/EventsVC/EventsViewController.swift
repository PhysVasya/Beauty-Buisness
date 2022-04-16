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
    
    private var eventsCollectionView: UICollectionView!
    private let segmentedControl = UISegmentedControl()
    
    private var dateForEvents: Day? {
        didSet {
            reloadEvents()
            updateSegmentedControl()
            
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
    private var dataSource: UICollectionViewDiffableDataSource<String, Event>?
    
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
        
        
        setupEventsCollectionView()
        dataSource = configureDataSource()
        setupAddNewProcedureButton()
        setupSegmentedControl()
        setupNavigationBar()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadEvents()
    }
    
    private func reloadEvents () {
        Task {
            guard let dateForEvents = dateForEvents else {
                return
            }
            fetchedEvents = await EventsFetchingManager.shared.fetchEventsForToday(dateForEvents, delegate: self)
        }
        
    }
    
    private func configureDataSource() -> UICollectionViewDiffableDataSource<String, Event> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Event> { cell, indexPath, itemIdentifier in
            var config = cell.defaultContentConfiguration()
            config.text = itemIdentifier.procedure?.name
            
            let masterName = itemIdentifier.master?.name
            //            let clientName = itemIdentifier.customer?.name
            let eventStartHour = itemIdentifier.startHour
            let eventStartMinute = itemIdentifier.startMinute
            let eventEndHour = itemIdentifier.endHour
            let eventEndMinute = itemIdentifier.endMinute
            config.secondaryText = "У \(masterName ?? "") с \(eventStartHour):\(eventStartMinute) до \(eventEndHour):\(eventEndMinute)"
            cell.contentConfiguration = config
        }
        
        return UICollectionViewDiffableDataSource(collectionView: eventsCollectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
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
    
    private func setupEventsCollectionView () {
        
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        
        listConfig.trailingSwipeActionsConfigurationProvider = { indexPath -> UISwipeActionsConfiguration in
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] action, view, completion in
                
                guard let eventToDelete = self?.fetchedEvents?.object(at: indexPath),
                      var currentSnapshot = self?.dataSource?.snapshot() else { return }
                
                currentSnapshot.deleteItems([eventToDelete])
                self?.dataSource?.apply(currentSnapshot, animatingDifferences: true) {
                    EventsFetchingManager.shared.deleteEvent(eventToDelete)
                }
                
            }
            deleteAction.backgroundColor = .myAccentColor
            deleteAction.image = UIImage(systemName: "trash.fill")
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        eventsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(eventsCollectionView)
        eventsCollectionView.frame = view.bounds
        eventsCollectionView.delegate = self
        eventsCollectionView.backgroundColor = .myBackgroundColor
        
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
    
    private func setupBGView (usingResultsFrom controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let subviews = view.subviews
        
        if controller.sections?.count == 0 || controller.sections == nil || controller.fetchedObjects?.count == 0 {
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
        navigationItem.title = UserDefaults.standard.string(forKey: "SALON-NAME")
        
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


extension EventsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    //
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //        guard let date = dateForEvents,
    //              let eventDate = Calendar.current.date(from: DateComponents(year: date.year, month: date.month, day: date.day)) else { return nil }
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "EEEE, dd/MM"
    //        let formattedDate = formatter.string(from: eventDate)
    //        let dateLabel = UILabel()
    //        dateLabel.backgroundColor = .myBackgroundColor
    //        dateLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
    //        dateLabel.text = formattedDate.capitalized
    //        dateLabel.font = .systemFont(ofSize: 24, weight: .bold)
    //        dateLabel.textColor = .label
    //        dateLabel.textAlignment = .center
    //        dateLabel.backgroundColor = .myHighlightColor
    //
    //        return dateLabel
    //
    //
    //    }
    
}

extension EventsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        var diffSnapshot = NSDiffableDataSourceSnapshot<String, Event>()
        
        snapshot.sectionIdentifiers.forEach { section in
            diffSnapshot.appendSections([section as! String])
            
            let items = snapshot.itemIdentifiersInSection(withIdentifier: section).map { (objectID: Any) -> Event in
                let oid = objectID as! NSManagedObjectID
                
                return controller.managedObjectContext.object(with: oid) as! Event
            }
            diffSnapshot.appendItems(items, toSection: section as? String)
        }
        
        dataSource?.apply(diffSnapshot)
        
        setupBGView(usingResultsFrom: controller)
        newEventObservableElements.events = controller.fetchedObjects?.count
        
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



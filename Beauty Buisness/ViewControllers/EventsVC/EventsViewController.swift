//
//  MainViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 27.03.2022.
//

import Foundation
import UIKit
import SwiftUI
import CoreData

public enum Section: Hashable {
    case main
    case completed
}

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
    //    private var workingDay: WorkingDay?
    
    private var fetchedEventsResultsController: NSFetchedResultsController<Event>?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Event>!
    
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
        configureDataSource()
        setupAddNewProcedureButton()
        setupSegmentedControl()
        setupNavigationBar()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        reloadEvents()
    }
    
    private func reloadEvents () {
        fetchedEventsResultsController = EventsFetchingManager.shared.fetchEventsForToday(dateForEvents!, delegate: self)
    }
    
    //Configuring DataSource
    private func configureDataSource() {
        
        //Cell registration for dataSource which is applied using closure, kind of CellForRowAtIndexPath, takes in cell, indexPath and item which is passed to dataSource as 2nd var
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Event> { cell, indexPath, event in
            
            var config = cell.defaultContentConfiguration()
            
            let procedureName =  event.procedure?.name
            let masterName = event.master?.name
            //            let clientName = itemIdentifier.customer?.name
            let eventStartHour = event.startHour
            let eventStartMinute = event.startMinute
            let eventEndHour = event.endHour
            let eventEndMinute = event.endMinute
            
            config.text = procedureName
            config.secondaryText = "У \(masterName ?? "") с \(eventStartHour):\(eventStartMinute) до \(eventEndHour):\(eventEndMinute)"
            
            cell.contentConfiguration = config
        }
        
        //Header registration for dataSource whit is AGAIN applied using closure which takes in 1.VIEW, 2. ELEMENTKIND ??? DFQ is this 3. IndexPath.
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            
            //MARK: - MISTAKE ? ?
            //Taking sectionID from dataSource which is passed in as 1st param (custom Section enum) ????
            
            print(indexPath.section)
            guard let sectionID = self?.dataSource.sectionIdentifier(for: indexPath.section) else { return }
            
            print(sectionID)
            //There will be 2 types of sections: label represents the date, second - the event completion
            switch sectionID {
            case .main:
                headerView.label.text = self?.dateForEvents?.dateFormatted()
            case .completed:
                headerView.label.text = "Завершенные"
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: eventsCollectionView) { collectionView, indexPath, event in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: event)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration , for: indexPath)
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
        listConfig.backgroundColor = .myBackgroundColor
        listConfig.headerMode = .supplementary
        
        listConfig.trailingSwipeActionsConfigurationProvider = { indexPath -> UISwipeActionsConfiguration in
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] action, view, completion in
                
                guard let eventToDelete = self?.dataSource.itemIdentifier(for: indexPath),
                      var currentSnapshot = self?.dataSource.snapshot() else { return }
                
                EventsFetchingManager.shared.deleteEvent(eventToDelete)

                currentSnapshot.deleteItems([eventToDelete])
                self?.dataSource.apply(currentSnapshot, animatingDifferences: view.window != nil)
                
            }
            deleteAction.backgroundColor = .myAccentColor
            deleteAction.image = UIImage(systemName: "trash.fill")
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        listConfig.leadingSwipeActionsConfigurationProvider = { indexPath -> UISwipeActionsConfiguration in
            
            let completeAction = UIContextualAction(style: .destructive, title: "Выполнено") { [weak self] action, view, completion in
                
                guard let eventToComplete = self?.dataSource.itemIdentifier(for: indexPath),
                      var currentSnapShot = self?.dataSource.snapshot() else { return }
                
                EventsFetchingManager.shared.updateEvent(eventToComplete)
                
                currentSnapShot.reconfigureItems([eventToComplete])
//                currentSnapShot.reloadSections([.completed])

                self?.dataSource.apply(currentSnapShot, animatingDifferences: view.window != nil)
                
            }
            completeAction.backgroundColor = .myHighlightColor
            
            completeAction.image = UIImage(systemName: "eye.slash.fill")
            return UISwipeActionsConfiguration(actions: [completeAction])
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
            if let noEventsView = subviews.first(where: { $0.restorationIdentifier == "NoEvents" }) {
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
    
}


extension EventsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

extension EventsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        //Cast down to general type
        let providedSnapShit = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        
        //Creating snapshot
        var diffSnapshot = NSDiffableDataSourceSnapshot<Section, Event>()
        
        //Looping through providedSnapSHIT section identifiers which are provided by sectionKeyPathIdentifier from NSFetchResultsController, WHICH is == #keyPath(Event.isCompleted), so the IDs are 0 and 1 (only 2)
        providedSnapShit.sectionIdentifiers.forEach { sectionID in
            
            //Kind of casting down sectionIDs to my custom created enum cases
            var section: Section {
                return sectionID == "0" ? Section.main : Section.completed
            }
            print(section)
            
            //Getting the events casted down from general NSManagedObjectID by accessing managedObjectContext
            let events = snapshot.itemIdentifiersInSection(withIdentifier: sectionID).compactMap { (objectID: Any) -> Event? in
                let event = controller.managedObjectContext.object(with: objectID as! NSManagedObjectID) as! Event
                return event
            }
            
            print(events.count)
            
            diffSnapshot.appendSections([section])
            diffSnapshot.appendItems(events, toSection: section)
        }
        
        //Applying snapSHIT
        dataSource.apply(diffSnapshot)
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



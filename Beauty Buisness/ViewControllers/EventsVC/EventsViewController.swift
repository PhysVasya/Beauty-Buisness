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
    
    private var newProcedureButtonTapped: (() -> Void)?
    private var newEventObservableElements = ObservableElementsForNewProcedureButton()
    private var workingDay: WorkingDay?
    
    private let eventsTableView: UITableView = {
        let tv = UITableView()
        tv.register(EventsTableCell.self, forCellReuseIdentifier: EventsTableCell.cellIdentifier)
        tv.backgroundColor = .myBackgroundColor
        return tv
    }()
    
    private var fetchedEvents: NSFetchedResultsController<Event>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newProcedureButtonTapped = { [weak self] in
            let newEventVC = UINavigationController(rootViewController: NewEventViewController())
            if let sheet = newEventVC.sheetPresentationController {
                sheet.detents = [.large()]
            }
            self?.navigationController?.present(newEventVC, animated: true)
               
        }
        
        navigationItem.title = UserDefaults.standard.string(forKey: "SALON-NAME")
        
        setupTableView()
        setupAddNewProcedureButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Each time the view appears (i.e. after changing settings also, the next methods are called to reload tableView
        reloadEvents { [weak self] in
            self?.eventsTableView.reloadData()
        }
    }
    
    private func reloadEvents (reload: (() -> Void)? = nil) {
        Task {
            fetchedEvents = await EventsFetchingManager.shared.fetchEventsForToday(Date())
            fetchedEvents?.delegate = self
            newEventObservableElements.events = fetchedEvents?.sections?[0].numberOfObjects
            reload?()
            setupBGView()
        }
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
        
        //Just a blank.
        config.secondaryText = "TEXT"
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

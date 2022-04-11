//
//  MastersViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 09.04.2022.
//

import Foundation
import UIKit
import CoreData
import SwiftUI


class MastersViewController: UIViewController {
    
    private let mastersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MastersTableCell.self, forCellReuseIdentifier: MastersTableCell.identifier)
        tableView.backgroundColor = UIColor.myBackgroundColor
        return tableView
    }()
    
    private var fetchedMasters: NSFetchedResultsController<Master>?
    private var addNewMasterButtonPressed: (() -> Void)?
    private var newMasterObservableElements = ObservableElementsForNewProcedureButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Мастера"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        addNewMasterButtonPressed = { [weak self] in
            let newMasterVC = UINavigationController(rootViewController: NewMasterViewController())
            if let sheets = newMasterVC.sheetPresentationController {
                sheets.prefersScrollingExpandsWhenScrolledToEdge = false
                sheets.detents = [.medium()]
            }
            self?.navigationController?.present(newMasterVC, animated: true)
        }
        
        setupMastersTableView()
        setupAddNewMasterButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMasters()
    }
    
    private func reloadMasters () {
        Task {
            fetchedMasters = await MastersFetchingManager.shared.fetchMasters()
            fetchedMasters?.delegate = self
            mastersTableView.reloadData()
            setupBGView()
        }
    }
    
    private func setupMastersTableView () {
        view.addSubview(mastersTableView)
        mastersTableView.frame = view.bounds
        mastersTableView.delegate = self
        mastersTableView.dataSource = self
    }
    
    private func setupAddNewMasterButton () {
        newMasterObservableElements.events = fetchedMasters?.sections?.count
        let newMasterButton = UIHostingController(rootView: NewProcedureButton(name: "Добавить мастера", elements: newMasterObservableElements, tap: addNewMasterButtonPressed)).view!
        view.addSubview(newMasterButton)
        newMasterButton.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        newMasterButton.backgroundColor = .clear
        newMasterButton.translatesAutoresizingMaskIntoConstraints = false
        newMasterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 8).isActive = true
        newMasterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupBGView () {
        let subviews = view.subviews
        
        if fetchedMasters?.sections?.count == 0 || fetchedMasters?.sections == nil || fetchedMasters?.sections?[0].objects?.count == 0 {
            if let noEventsView = subviews.first(where: {$0.restorationIdentifier == "NoMasters"}) {
                if subviews.contains(noEventsView) {
                    //                    noEventsView.removeFromSuperview()
                }
            } else {
                let noEventsLabel = UILabel()
                noEventsLabel.text = "Пока мастера не указаны..."
                noEventsLabel.font = .systemFont(ofSize: 24, weight: .bold)
                noEventsLabel.textColor = .systemGray4
                noEventsLabel.textAlignment = .center
                noEventsLabel.frame = view.bounds
                noEventsLabel.restorationIdentifier = "NoMasters"
                view.addSubview(noEventsLabel)
            }
        } else {
            if let noEventsView = subviews.first(where: {$0.restorationIdentifier == "NoMasters"}) {
                if subviews.contains(noEventsView) {
                    noEventsView.removeFromSuperview()
                }
            }
        }
    }
}

extension MastersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedMasters?.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedMasters?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MastersTableCell.identifier, for: indexPath)
        let master = fetchedMasters?.object(at: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = master?.name
        config.secondaryText = master?.phone
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] action, view, handler in
            guard let masterToDelete = self?.fetchedMasters?.object(at: indexPath) else {
                return
            }
            MastersFetchingManager.shared.deleteMaster(masterToDelete)
            
        }
        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
    
}

extension MastersViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mastersTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            mastersTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            mastersTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            mastersTableView.deleteRows(at: [indexPath!], with: .automatic)
            mastersTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            let cell = mastersTableView.cellForRow(at: indexPath!)
            let master = controller.object(at: indexPath!) as? Master
            
            var config = cell?.defaultContentConfiguration()
            config?.text = master?.name
            config?.secondaryText = master?.phone
        @unknown default:
            print("Unknown NSFetchResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mastersTableView.endUpdates()
    }
    
}

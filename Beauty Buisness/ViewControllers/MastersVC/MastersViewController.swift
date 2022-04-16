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
    
    private var mastersCollectionView: UICollectionView!
    
    private var fetchedMasters: NSFetchedResultsController<Master>?
    private var dataSource: UICollectionViewDiffableDataSource<String, Master>?
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
        
        setupMastersCollectionView()
        setupAddNewMasterButton()
        dataSource = configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMasters()
    }
    
    private func reloadMasters () {
        Task {
            fetchedMasters = await MastersFetchingManager.shared.fetchMasters(self)
        }
    }
    
    private func configureDataSource () -> UICollectionViewDiffableDataSource<String, Master> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Master> { cell, indexPath, itemIdentifier in
            var config = cell.defaultContentConfiguration()
            config.text = itemIdentifier.name
            config.secondaryText = itemIdentifier.phone
            cell.contentConfiguration = config
         
        }
        return UICollectionViewDiffableDataSource(collectionView: mastersCollectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
    
    private func setupMastersCollectionView () {
        
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.trailingSwipeActionsConfigurationProvider = { indexPath -> UISwipeActionsConfiguration in
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { action, view, completion in
                
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        layoutConfig.backgroundColor = .myBackgroundColor
        
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        mastersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(mastersCollectionView)
        mastersCollectionView.backgroundColor = .myBackgroundColor
        mastersCollectionView.frame = view.bounds
        mastersCollectionView.delegate = self
    }
    
    private func setupAddNewMasterButton () {
        let newMasterButton = UIHostingController(rootView: NewProcedureButton(name: "Добавить мастера", elements: newMasterObservableElements, tap: addNewMasterButtonPressed)).view!
        view.addSubview(newMasterButton)
        newMasterButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        newMasterButton.backgroundColor = .clear
        newMasterButton.translatesAutoresizingMaskIntoConstraints = false
        newMasterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 8).isActive = true
        newMasterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupBGView (usingResultsFrom controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let subviews = view.subviews
        
        if controller.sections?.count == 0 || controller.sections == nil || controller.fetchedObjects?.count == 0 {
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

extension MastersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchedMasters?.sections?[section].numberOfObjects ?? 0
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return fetchedMasters?.sections?.count ?? 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: MastersTableCell.identifier, for: indexPath)
//        let master = fetchedMasters?.object(at: indexPath)
//
//        var config = cell.defaultContentConfiguration()
//        config.text = master?.name
//        config.secondaryText = master?.phone
//        cell.contentConfiguration = config
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        guard let chosenMaster = fetchedMasters?.object(at: indexPath),
//              let masterNumber = URL(string: "telprompt://\(chosenMaster.phone!)" ) else { return }
//        UIApplication.shared.open(masterNumber, options: [:], completionHandler: nil)
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] action, view, handler in
//            guard let masterToDelete = self?.fetchedMasters?.object(at: indexPath) else {
//                return
//            }
//            MastersFetchingManager.shared.deleteMaster(masterToDelete)
//
//        }
//        deleteAction.image = UIImage(systemName: "trash.fill")
//        deleteAction.backgroundColor = .myAccentColor
//        let config = UISwipeActionsConfiguration(actions: [deleteAction])
//        return config
//    }
//
}

extension MastersViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        var diffSnapshot = NSDiffableDataSourceSnapshot<String, Master>()
        
        snapshot.sectionIdentifiers.forEach { section in
            diffSnapshot.appendSections([section as! String])
            
            let items = snapshot.itemIdentifiersInSection(withIdentifier: section).map { (objectID: Any) -> Master in
                let oid = objectID as! NSManagedObjectID
                
                return controller.managedObjectContext.object(with: oid) as! Master
            }
            diffSnapshot.appendItems(items, toSection: section as? String)
        }
        dataSource?.apply(diffSnapshot)
        setupBGView(usingResultsFrom: controller)
        newMasterObservableElements.events = controller.fetchedObjects?.count
        
    }
    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        mastersCollectionView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        reloadMasters()
//
//        switch type {
//        case .insert:
//            mastersCollectionView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .delete:
//            mastersCollectionView.deleteRows(at: [indexPath!], with: .automatic)
//        case .move:
//            mastersCollectionView.deleteRows(at: [indexPath!], with: .automatic)
//            mastersCollectionView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .update:
//            let cell = mastersCollectionView.cellForRow(at: indexPath!)
//            let master = controller.object(at: indexPath!) as? Master
//
//            var config = cell?.defaultContentConfiguration()
//            config?.text = master?.name
//            config?.secondaryText = master?.phone
//        @unknown default:
//            print("Unknown NSFetchResultsChangeType")
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        mastersCollectionView.endUpdates()
//    }
    
}

extension MastersViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newMasterObservableElements.offset = scrollView.contentOffset.y 
    }
}

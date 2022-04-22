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

    private enum MastersSection: Hashable {
    
        case prioritisedMaster
        case lowPriorityMaster
        case casualMaster
        case unidentified
        
        var title: String? {
            switch self {
            case .prioritisedMaster:
                return "Лучшие"
            case .lowPriorityMaster:
                return "Сомнительные"
            case .casualMaster:
                return "Обычные"
            case .unidentified:
                return nil
            }
        }
    }
    
    private enum SwipeAction {
        case leading
        case trailing
    }
    
    private var mastersCollectionView: UICollectionView!
    
    private var fetchedMasterResultsController: NSFetchedResultsController<Master>?
    private var mastersDataSource: UICollectionViewDiffableDataSource<MastersSection, Master>!
    
    
    private var addNewMasterButtonPressed: (() -> Void)?
    private var newMasterObservableElements = ObservableElementsForNewProcedureButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Мастера"
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
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMasters()
    }
    
    private func reloadMasters () {
        
        fetchedMasterResultsController = MastersFetchingManager.shared.fetchMasters(self)
    }
    
    private func configureDataSource () {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Master> { cell, indexPath, itemIdentifier in
            var config = cell.defaultContentConfiguration()
            config.text = itemIdentifier.name
            config.secondaryText = itemIdentifier.phone
            cell.contentConfiguration = config
            
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            
            guard let sectionID = self?.mastersDataSource.sectionIdentifier(for: indexPath.section) else { return }
            
            headerView.configureHeader(text: sectionID.title)
   
        }
        
        mastersDataSource = UICollectionViewDiffableDataSource(collectionView: mastersCollectionView, cellProvider: { collectionView, indexPath, master -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: master)
        })
        
        mastersDataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath -> UICollectionReusableView? in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
                
    }
    
    private func setupMastersCollectionView () {
        
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        layoutConfig.headerMode = .supplementary
        
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath -> UISwipeActionsConfiguration? in
            guard let trailingAction = self?.configureSwipeActions(action: .trailing, for: indexPath) else { return nil }
            return UISwipeActionsConfiguration(actions: [trailingAction])
        }
        
        layoutConfig.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath -> UISwipeActionsConfiguration? in
            guard let leadingAction = self?.configureSwipeActions(action: .leading, for: indexPath) else { return nil }
            return UISwipeActionsConfiguration(actions: [leadingAction])
        }
        
        layoutConfig.backgroundColor = .myBackgroundColor
        
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        mastersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(mastersCollectionView)
        mastersCollectionView.backgroundColor = .myBackgroundColor
        mastersCollectionView.frame = view.bounds
        mastersCollectionView.delegate = self
    }
    
    private func configureSwipeActions (action: SwipeAction, for indexPath: IndexPath) -> UIContextualAction? {
        
        switch action {
        case .leading:
            guard let masterToChangeRating = mastersDataSource.itemIdentifier(for: indexPath) else { return nil }
            let changeRatingAction = UIContextualAction(style: .normal, title: nil) { action, view, completion in
                if masterToChangeRating.rating == 5 {
                    MastersFetchingManager.shared.updateMaster(masterToChangeRating, setRating: 3)
                } else {
                    MastersFetchingManager.shared.updateMaster(masterToChangeRating, setRating: 5)
                }
            }
            if masterToChangeRating.rating == 5 {
                changeRatingAction.image = UIImage(systemName: "star.slash")
            } else {
                changeRatingAction.image = UIImage(systemName: "star")
            }
            changeRatingAction.backgroundColor = .myHighlightColor
            return changeRatingAction
            
        case .trailing:
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] action, view, completion in
                
                guard let masterToDelete = self?.mastersDataSource.itemIdentifier(for: indexPath) else { return }
                
                MastersFetchingManager.shared.deleteMaster(masterToDelete)
                
            }
            deleteAction.backgroundColor = .myAccentColor
            deleteAction.image = UIImage(systemName: "trash.fill")
            return deleteAction
        }
        
        
    }
    
    
    private func setupAddNewMasterButton () {
        let newMasterButton = UIHostingController(rootView: NewProcedureButton(name: "Добавить мастера", elements: newMasterObservableElements, tap: addNewMasterButtonPressed)).view!
        view.addSubview(newMasterButton)
        newMasterButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        newMasterButton.backgroundColor = .clear
        newMasterButton.translatesAutoresizingMaskIntoConstraints = false
        newMasterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 7).isActive = true
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
    

  
    
}

extension MastersViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        let providedSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        
        

        var diffSnapshot = NSDiffableDataSourceSnapshot<MastersSection, Master>()
        
        providedSnapshot.sectionIdentifiers.forEach { sectionID in

            var section: MastersSection {
                if sectionID == "5" {
                    return .prioritisedMaster
                } else if sectionID == "4" || sectionID == "3" {
                    return .casualMaster
                } else if sectionID == "2" || sectionID == "1" {
                    return .lowPriorityMaster
                } else {
                    return .unidentified
                }
            }
            
            let masters = snapshot.itemIdentifiersInSection(withIdentifier: sectionID).compactMap { (objectID: Any) -> Master in
                let oid = objectID as! NSManagedObjectID
                return controller.managedObjectContext.object(with: oid) as! Master
            }

            diffSnapshot.appendSections([section])
            diffSnapshot.appendItems(masters, toSection: section)
            
        }

        mastersDataSource.apply(diffSnapshot)
        setupBGView(usingResultsFrom: controller)
        newMasterObservableElements.events = controller.fetchedObjects?.count
        
    }
    
}

extension MastersViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newMasterObservableElements.offset = scrollView.contentOffset.y
    }
}

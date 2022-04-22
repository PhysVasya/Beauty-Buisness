//
//  CustomersViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 09.04.2022.
//

import Foundation
import UIKit
import CoreData
import SwiftUI


class CustomersViewController: UIViewController {
    
    private enum CustomersSection: Hashable {
        case highPriorityCustomer
        case lowPriorityCustomers
        case casualCustomers
        case unidentified
        
        var title: String? {
            switch self {
            case .highPriorityCustomer:
                return "Приоритетные"
            case .lowPriorityCustomers:
                return "Низкоприоритетные"
            case .casualCustomers:
                return "Обычные"
            case .unidentified:
                return nil
            }
        }
    }
    
    private var customersCollectionView: UICollectionView!
    
    private var customersDataSource: UICollectionViewDiffableDataSource<CustomersSection, Customer>!
    private var fetchedCustomerResultsController: NSFetchedResultsController<Customer>?
    
    private let newCustomerObservableElements = ObservableElementsForNewProcedureButton()
    private var newCustomerButtonPressed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Клиенты"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        newCustomerButtonPressed = { [weak self] in
            let newCustomerVC = UINavigationController(rootViewController: NewCustomerViewController())
            if let sheet = newCustomerVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            self?.navigationController?.present(newCustomerVC, animated: true)
        }
        
        setupCustomersCollectionView()
        setupDataSource()
        setupNewCustomerButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCustomers()
    }
    
    private func reloadCustomers () {
        fetchedCustomerResultsController = CustomersFetchingManager.shared.fetchCustomers(delegate: self)
    }
    
    private func setupDataSource () {
        
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Customer> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            content.secondaryText = item.phone
            cell.contentConfiguration = content
            
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            
            guard let sectionID = self?.customersDataSource.sectionIdentifier(for: indexPath.section) else { return }
            
            headerView.configureHeader(text: sectionID.title)
        }
        
        customersDataSource = UICollectionViewDiffableDataSource(collectionView: customersCollectionView) { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        customersDataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
    }
    
    private func setupCustomersCollectionView () {
        
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        layoutConfig.backgroundColor = .myBackgroundColor
        layoutConfig.headerMode = .supplementary
        
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath -> UISwipeActionsConfiguration in
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { action, view, completion in
                guard let customerToDelete = self?.fetchedCustomerResultsController?.object(at: indexPath) else { return }
                
                CustomersFetchingManager.shared.deleteCustomer(customerToDelete)
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = .myAccentColor
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        customersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        customersCollectionView.backgroundColor = .myBackgroundColor
        customersCollectionView.collectionViewLayout = layout
        
        view.addSubview(customersCollectionView)
        customersCollectionView.frame = view.bounds
        customersCollectionView.delegate = self
    }
    
    
    private func setupNewCustomerButton () {
        let button = UIHostingController(rootView: NewProcedureButton(name: "Добавить клиента", elements: newCustomerObservableElements, tap: newCustomerButtonPressed)).view!
        view.addSubview(button)
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 7).isActive = true
    }
    
    private func setupBGView (withReceivedResultsFrom controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let subviews = view.subviews
        
        if controller.sections?.count == 0 || controller.sections == nil || controller.fetchedObjects?.count == 0 {
            if let noEventsView = subviews.first(where: {$0.restorationIdentifier == "NoClients"}) {
                if subviews.contains(noEventsView) {
                    //                    noEventsView.removeFromSuperview()
                }
            } else {
                let noEventsLabel = UILabel()
                noEventsLabel.text = "Пока клиентов нет..."
                noEventsLabel.font = .systemFont(ofSize: 24, weight: .bold)
                noEventsLabel.textColor = .systemGray4
                noEventsLabel.textAlignment = .center
                noEventsLabel.frame = view.bounds
                noEventsLabel.restorationIdentifier = "NoClients"
                view.addSubview(noEventsLabel)
            }
        } else {
            if let noEventsView = subviews.first(where: {$0.restorationIdentifier == "NoClients"}) {
                if subviews.contains(noEventsView) {
                    noEventsView.removeFromSuperview()
                }
            }
        }
    }
}


extension CustomersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let chosenCustomer = fetchedCustomerResultsController?.object(at: indexPath),
              let chosenCustomerNumber = chosenCustomer.phone,
              let phoneURL = URL(string: "telprompt://\(chosenCustomerNumber)") else { return }
        
        
        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        
    }
    
}



extension CustomersViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        let providedSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        
        var diffSnapShit = NSDiffableDataSourceSnapshot<CustomersSection, Customer>()
        
        providedSnapshot.sectionIdentifiers.forEach { sectionID in
            
            var section: CustomersSection {
                if sectionID == "5" {
                    return .highPriorityCustomer
                } else if sectionID == "4" || sectionID == "3" {
                    return .casualCustomers
                } else if sectionID == "2" || sectionID == "1" {
                    return .lowPriorityCustomers
                } else {
                    return .unidentified
                }
            }
            
            let customers = snapshot.itemIdentifiersInSection(withIdentifier: sectionID).compactMap { (objectID: Any) -> Customer? in
                let customer = controller.managedObjectContext.object(with: objectID as! NSManagedObjectID) as! Customer
                return customer
            }
                        
            diffSnapShit.appendSections([section])
            diffSnapShit.appendItems(customers, toSection: section)
        }
        customersDataSource.apply(diffSnapShit)
        setupBGView(withReceivedResultsFrom: controller)
        newCustomerObservableElements.events = controller.fetchedObjects?.count
    }
    
}

extension CustomersViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newCustomerObservableElements.offset = scrollView.contentOffset.y
    }
    
}

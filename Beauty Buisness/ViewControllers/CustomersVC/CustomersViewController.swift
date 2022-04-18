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
    
    private var customersCollectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<String, Customer>?
    private var fetchedCustomers: NSFetchedResultsController<Customer>?
    private let newCustomerObservableElements = ObservableElementsForNewProcedureButton()
    private var newCustomerButtonPressed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Клиенты"
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadCustomers()
    }
    
    public func reloadCustomers () {
            fetchedCustomers =  CustomersFetchingManager.shared.fetchCustomers(delegate: self)
    }
    
    
    private func setupDataSource () {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Customer> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            content.secondaryText = item.phone
            cell.contentConfiguration = content
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: customersCollectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
    }
    
    private func setupCustomersCollectionView () {
        
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.backgroundColor = .myBackgroundColor
        
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath -> UISwipeActionsConfiguration in
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { action, view, completion in
                guard let customerToDelete = self?.fetchedCustomers?.object(at: indexPath),
                      var currentSnapshot = self?.dataSource?.snapshot() else { return }
                
                currentSnapshot.deleteItems([customerToDelete])
                self?.dataSource?.apply(currentSnapshot, animatingDifferences: view.window != nil) {
                    CustomersFetchingManager.shared.deleteCustomer(customerToDelete)
                    
                }
                
                
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
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 8).isActive = true
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
        
        guard let chosenCustomer = fetchedCustomers?.object(at: indexPath),
              let chosenCustomerNumber = chosenCustomer.phone,
              let phoneURL = URL(string: "telprompt://\(chosenCustomerNumber)") else { return }
        
        
        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        
    }
    
}



extension CustomersViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var diff = NSDiffableDataSourceSnapshot<String, Customer>()
        
        snapshot.sectionIdentifiers.forEach { section in
            diff.appendSections([section as! String])
            
            let items = snapshot.itemIdentifiersInSection(withIdentifier: section).map { (objectID: Any) -> Customer in
                let oid = objectID as! NSManagedObjectID
                return controller.managedObjectContext.object(with: oid) as! Customer
            }
            
            diff.appendItems(items, toSection: section as? String)
        }
        
        self.dataSource?.apply(diff)
        newCustomerObservableElements.events = controller.fetchedObjects?.count
        setupBGView(withReceivedResultsFrom: controller)
        
    }
    
}

extension CustomersViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newCustomerObservableElements.offset = scrollView.contentOffset.y
    }
}

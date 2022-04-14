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
    
    private let customersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CustomersTableCell.self, forCellReuseIdentifier: CustomersTableCell.identifier)
        tableView.backgroundColor = .myBackgroundColor
        return tableView
    }()
    
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
        
        setupCustomersTableView()
        setupNewCustomerButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCustomers { [weak self] in
            self?.customersTableView.reloadData()
        }
    }
    
    public func reloadCustomers (reload: (() -> Void)? = nil) {
        Task {
            fetchedCustomers = await CustomersFetchingManager.shared.fetchCustomers()
            fetchedCustomers?.delegate = self
            newCustomerObservableElements.events = fetchedCustomers?.sections?[0].numberOfObjects
            reload?()
            setupBGView()
        }
    }
    
    private func setupCustomersTableView () {
        view.addSubview(customersTableView)
        customersTableView.frame = view.bounds
        customersTableView.delegate = self
        customersTableView.dataSource = self
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
    
    private func setupBGView () {
        let subviews = view.subviews
        
        if fetchedCustomers?.sections?.count == 0 || fetchedCustomers?.sections == nil || fetchedCustomers?.sections?[0].objects?.count == 0 {
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


extension CustomersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomersTableCell.identifier, for: indexPath)
        let customer = fetchedCustomers?.object(at: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = customer?.name
        config.secondaryText = customer?.phone
        cell.contentConfiguration = config
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedCustomers?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedCustomers?.sections?[section].numberOfObjects ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let chosenCustomer = fetchedCustomers?.object(at: indexPath),
              let customerPhoneNumber = URL(string: "telprompt://\(chosenCustomer.phone!)") else { return }
        UIApplication.shared.open(customerPhoneNumber, options: [:], completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] action, view, handler in
            guard let customerToDelete = self?.fetchedCustomers?.object(at: indexPath) else {
                return
            }
            CustomersFetchingManager.shared.deleteCustomer(customerToDelete)
            handler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .myAccentColor

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
    
    
}


extension CustomersViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customersTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        reloadCustomers()
        switch type {
        case .insert:
            customersTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            customersTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            customersTableView.deleteRows(at: [indexPath!], with: .automatic)
            customersTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            let cell = customersTableView.cellForRow(at: indexPath!)
            let customer = controller.object(at: indexPath!) as? Customer
            
            var config = cell?.defaultContentConfiguration()
            config?.text = customer?.name
            config?.secondaryText = customer?.phone
            cell?.contentConfiguration = config
        @unknown default:
            print("Unexpected NSFetchResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customersTableView.endUpdates()
    }
    
}

extension CustomersViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newCustomerObservableElements.offset = scrollView.contentOffset.y
    }
}

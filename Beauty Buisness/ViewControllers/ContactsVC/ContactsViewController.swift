//
//  ContactsViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 14.04.2022.
//

import Foundation
import UIKit
import ContactsUI

class ContactsViewController: UIViewController {
    
    private let contactsTableView: UITableView = {
       let tableView = UITableView()
        tableView.register(ContactTableCell.self, forCellReuseIdentifier: ContactTableCell.identifier)
        tableView.backgroundColor = .myBackgroundColor
        return tableView
    }()
    private let searchController = UISearchController(searchResultsController: nil)
    public var importContactData: ((Contact?) -> Void)?

    
    private var contacts: [Contact]? {
        didSet {
            contactsTableView.reloadData()
        }
    }
    private var filteredContacts: [Contact]?
    private var chosenContact: Contact? {
        didSet {
            importContactData?(chosenContact)
            navigationController?.dismiss(animated: true)
        }
    }
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    private var isFiltering: Bool {
        return !isSearchBarEmpty && searchController.isActive
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContactsTableView()
        setupNavigationBar()
        showFetchedContacts()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSearchBar()
    }
    
    private func setupContactsTableView () {
        view.addSubview(contactsTableView)
        contactsTableView.frame = view.bounds
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
    }
    
    private func setupNavigationBar () {
        title = "Контакты"
        let cancelBarButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelContactsPresentation))
//        let importBarButton = UIBarButtonItem(title: "Импорт", style: .done , target: self, action: #selector(importChosenContacts))
        navigationItem.leftBarButtonItem = cancelBarButton
//        navigationItem.rightBarButtonItem = importBarButton
    }
    
    private func setupSearchBar () {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        searchController.definesPresentationContext = false
    }
    
    private func filterSearchResults (_ searchText: String) {
        
        // !!!!
        filteredContacts = contacts?.filter({ $0.name.lowercased().contains(searchText.lowercased()) || $0.phoneNumber != nil && $0.phoneNumber!.value.stringValue.contains(searchText) ? true : false })
        contactsTableView.reloadData()
    }
    
    private func showFetchedContacts () {
        Task {
           contacts = await ContactsFetchingManager.shared.fetchUserContacts()

        }
    }
    
    @objc private func cancelContactsPresentation () {
        navigationController?.dismiss(animated: true)
    }

}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredContacts?.count ?? 1
        }
        return contacts?.count ?? 1
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableCell.identifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        let contact: Contact?
        if isFiltering {
            contact = filteredContacts?[indexPath.row]
        } else {
            contact = contacts?[indexPath.row]
        }
        config.text = contact?.name
        config.secondaryText = contact?.phoneNumber?.value.stringValue
        config.image = contact?.image
        config.imageProperties.cornerRadius = 22
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isFiltering {
            chosenContact = filteredContacts?[indexPath.row]
        } else {
            chosenContact = contacts?[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height * 0.1
        
    }
    
    
}

extension ContactsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchResults(searchController.searchBar.text!)
        
    }
    
    
}




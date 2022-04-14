//
//  NewCustomerViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation
import UIKit
import PhoneNumberKit


class NewCustomerViewController: UIViewController {
    
    private let newCustomerTableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = true
        tableView.register(CustomersTableCell.self, forCellReuseIdentifier: CustomersTableCell.identifier)
        tableView.backgroundColor = .myBackgroundColor
        return tableView
    }()
    
    private let contactsViewController = ContactsViewController()
    private var newCustomer: Customer?
    private var customerName: String?
    private var customerNumber: String?
    private let nameTextField = UITextField()
    private let phoneNumberTextField = PhoneNumberTextField()
    
    private var textFieldDelegateSelection: UITextFieldDelegateSelection?
    private var importedContactFromContacts: ((Contact?) -> Void)?
    
    private var numberOfRowsForSection = [1, 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self
        textFieldDelegateSelection = self
        
        setupNewCustomerTableView()
        setupNavigationBar()
        setKeyboardDismissOnViewTap()
        
        importedContactFromContacts = { [weak self] contact in
            self?.customerName = contact?.name
            self?.customerNumber = contact?.phoneNumber?.value.stringValue
            self?.nameTextField.text = contact?.name
            self?.phoneNumberTextField.text = contact?.phoneNumber?.value.stringValue
            
        }
    }
    
    private func setupNewCustomerTableView() {
        view.addSubview(newCustomerTableView)
        newCustomerTableView.frame = view.bounds
        newCustomerTableView.delegate = self
        newCustomerTableView.dataSource = self
    }
    
    private func setupNavigationBar () {
        title = "Добавить клиента"
        let finishBarButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(finishBarButtonPressed))
        let cancelBarButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelBarButtonPressed))
        navigationItem.rightBarButtonItem = finishBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
    }
    
    private func setKeyboardDismissOnViewTap () {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureManager))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapGestureManager () {
        view.endEditing(true)
    }
    
    
    @objc private func finishBarButtonPressed () {
        
        guard let customerName = customerName,
              let customerNumber = customerNumber else {
            return
        }
        
        CustomersFetchingManager.shared.saveNewCustomer(customerName, customerNumber)
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func cancelBarButtonPressed () {
        navigationController?.dismiss(animated: true)
    }
}

extension NewCustomerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomersTableCell.identifier, for: indexPath)
        
        nameTextField.autocorrectionType = .no
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.contentView.addSubview(nameTextField)
            nameTextField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                nameTextField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                nameTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                nameTextField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 14)
            ])
            nameTextField.placeholder = "Введите имя клиента"
            nameTextField.tag = 0
            nameTextField.addTarget(self, action: #selector(onNameChange(_:)), for: .editingChanged)
            return cell

        }
        
        if indexPath.row == 1 {
            var config = cell.defaultContentConfiguration()
            config.text = "Найти в контактах"
            config.image = UIImage(systemName: "person.circle")
            cell.contentConfiguration = config
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            cell.contentView.addSubview(phoneNumberTextField)
            phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
            phoneNumberTextField.withFlag = true
            phoneNumberTextField.withExamplePlaceholder = true
            phoneNumberTextField.maxDigits = 10
            phoneNumberTextField.tag = 1
            NSLayoutConstraint.activate([
                phoneNumberTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                phoneNumberTextField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                phoneNumberTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                phoneNumberTextField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 14)
            ])
            

            phoneNumberTextField.addTarget(self, action: #selector(onPhoneChange(_:)), for: .editingChanged)
            return cell
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsForSection[section]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Имя"
        } else {
            return "Номер телефона"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactsVC = ContactsViewController()
        contactsVC.importContactData = importedContactFromContacts
        
        if indexPath.row == 1 {
            navigationController?.present(UINavigationController(rootViewController: contactsVC), animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension NewCustomerViewController: UITextFieldDelegate {
    
    @objc private func onNameChange (_ sender: UITextField) {
        customerName = sender.text
    }
    
    @objc private func onPhoneChange (_ sender: UITextField) {
        customerNumber = sender.text
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDelegateSelection?.didDeselectTextField(textField, at: textField.textFieldIndexPath)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDelegateSelection?.didSelectTextField(textField, at: textField.textFieldIndexPath)
    }
    
}

extension NewCustomerViewController: UITextFieldDelegateSelection {
    
    func didSelectTextField(_ textField: UITextField, at indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.newCustomerTableView.beginUpdates()
            self?.numberOfRowsForSection[indexPath.section] += 1
            let newRow = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            self?.newCustomerTableView.insertRows(at: [newRow], with: .automatic)
            self?.newCustomerTableView.endUpdates()
        }
    }
    
    func didDeselectTextField(_ textField: UITextField, at indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            
            self?.newCustomerTableView.beginUpdates()
            self?.numberOfRowsForSection = [1, 1]
            let rowToDelete = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            self?.newCustomerTableView.deleteRows(at: [rowToDelete], with: .automatic)
            self?.newCustomerTableView.endUpdates()
        }
    }
    
    
}

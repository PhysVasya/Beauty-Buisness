//
//  NewMasterViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation
import UIKit
import PhoneNumberKit
import Contacts
import ContactsUI


class NewMasterViewController: UIViewController {
    
    private let newMasterTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewMasterTableCell.self, forCellReuseIdentifier: NewMasterTableCell.identifier)
        tableView.backgroundColor = .myBackgroundColor
        tableView.allowsSelection = true
        return tableView
    }()
    
    private let phoneNumberKitTextField = PhoneNumberTextField()
    private let nameTextField = UITextField()
    private var newMasterName: String?
    private var newMasterNumber: String?
    private var newMaster: Master?
    
    private var contactImportedFromContacts: ((Contact?) -> Void)?
    
    private var textFieldSelectionDelegate: UITextFieldDelegateSelection?
    private var numberOfRowsForSection = [1, 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        phoneNumberKitTextField.delegate = self
        textFieldSelectionDelegate = self
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberKitTextField.translatesAutoresizingMaskIntoConstraints = false
        
        setupNewMasterTableView()
        setupNavigationBar()
        setKeyboardDismissOnViewTap()
        
        contactImportedFromContacts = { [weak self] contact in
            self?.nameTextField.text = contact?.name
            self?.phoneNumberKitTextField.text = contact?.phoneNumber?.value.stringValue
            self?.newMasterName = contact?.name
            self?.newMasterNumber = contact?.phoneNumber?.value.stringValue
            
        }
    }
    
    private func setupNewMasterTableView () {
        view.addSubview(newMasterTableView)
        newMasterTableView.frame = view.bounds
        newMasterTableView.delegate = self
        newMasterTableView.dataSource = self
    }
    
    private func setupNavigationBar () {
        title = "Добавить мастера"
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
        
        guard let newMasterName = newMasterName,
              let newMasterNumber = newMasterNumber else {
            return
        }
        
        MastersFetchingManager.shared.saveNewMaster(newMasterName, newMasterNumber)
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func cancelBarButtonPressed () {
        navigationController?.dismiss(animated: true)
    }
    
}


extension NewMasterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NewMasterTableCell.identifier, for: indexPath)
        
        nameTextField.autocorrectionType = .no
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.contentView.addSubview(nameTextField)
            NSLayoutConstraint.activate([
                nameTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                nameTextField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                nameTextField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 14),
                nameTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
            ])
            nameTextField.placeholder = "Укажите имя сотрудника"
            nameTextField.addTarget(self, action: #selector(nameTextFieldChanged(_:)), for: .editingChanged)
            nameTextField.tag = 0
            
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
            cell.contentView.addSubview(phoneNumberKitTextField)
            NSLayoutConstraint.activate([
                phoneNumberKitTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                phoneNumberKitTextField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                phoneNumberKitTextField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 14),
                phoneNumberKitTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
            ])
            phoneNumberKitTextField.withFlag = true
            phoneNumberKitTextField.tag = 1
            phoneNumberKitTextField.withExamplePlaceholder = true
            phoneNumberKitTextField.maxDigits = 10
            phoneNumberKitTextField.addTarget(self, action: #selector(numberTextFieldChanged(_:)), for: .editingChanged)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Имя"
        } else {
            return "Номер телефона"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactsVC = ContactsViewController()
        contactsVC.importContactData = contactImportedFromContacts

        if indexPath.row == 1 {
            navigationController?.present(UINavigationController(rootViewController: contactsVC), animated: true)
        }
      
        tableView.deselectRow(at: indexPath, animated: true)
     
        
    }
    
}


extension NewMasterViewController: UITextFieldDelegate {
    
    @objc private func nameTextFieldChanged (_ sender: UITextField) {
        newMasterName = sender.text
    }
    
    @objc private func numberTextFieldChanged (_ sender: UITextField) {
        newMasterNumber = sender.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldSelectionDelegate?.didSelectTextField(textField, at: textField.textFieldIndexPath)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldSelectionDelegate?.didDeselectTextField(textField, at: textField.textFieldIndexPath)
    }
}

extension NewMasterViewController: UITextFieldDelegateSelection {
    
    func didSelectTextField(_ textField: UITextField, at indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.newMasterTableView.beginUpdates()
            self?.numberOfRowsForSection[indexPath.section] += 1
            let newRow = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            self?.newMasterTableView.insertRows(at: [newRow], with: .automatic)
            self?.newMasterTableView.endUpdates()
        }
        
    }
    
    func didDeselectTextField(_ textField: UITextField, at indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            
            self?.newMasterTableView.beginUpdates()
            self?.numberOfRowsForSection = [1, 1]
            let rowToDelete = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            self?.newMasterTableView.deleteRows(at: [rowToDelete], with: .automatic)
            self?.newMasterTableView.endUpdates()
        }
    }
    
    
}








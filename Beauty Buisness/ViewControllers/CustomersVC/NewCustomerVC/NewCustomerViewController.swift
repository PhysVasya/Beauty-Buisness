//
//  NewCustomerViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation
import UIKit


class NewCustomerViewController: UIViewController {
    
    private let newCustomerTableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.register(CustomersTableCell.self, forCellReuseIdentifier: CustomersTableCell.identifier)
        tableView.backgroundColor = .myBackgroundColor
        return tableView
    }()
    
    private var newCustomer: Customer?
    private var customerName: String?
    private var customerNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNewCustomerTableView()
        setupNavigationBar()
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
        let textField = UITextField()
        textField.delegate = self
        textField.autocorrectionType = .no
        cell.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 14)
        ])
        if indexPath.section == 0 {
            textField.placeholder = "Введите имя клиента"
            textField.addTarget(self, action: #selector(onNameChange(_:)), for: .editingChanged)
        } else {
            textField.keyboardType = .phonePad
            textField.placeholder = "Введите номер телефона клиента"
            textField.addTarget(self, action: #selector(onPhoneChange(_:)), for: .editingChanged)
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    
}

extension NewCustomerViewController: UITextFieldDelegate {
    
    @objc private func onNameChange (_ sender: UITextField) {
        customerName = sender.text
    }
    
    @objc private func onPhoneChange (_ sender: UITextField) {
        customerNumber = sender.text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}

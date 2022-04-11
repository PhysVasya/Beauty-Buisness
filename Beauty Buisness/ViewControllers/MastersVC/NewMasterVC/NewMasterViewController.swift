//
//  NewMasterViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation
import UIKit


class NewMasterViewController: UIViewController {
    
    private let newMasterTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewMasterTableCell.self, forCellReuseIdentifier: NewMasterTableCell.identifier)
        tableView.backgroundColor = .myBackgroundColor
        tableView.allowsSelection = false
        return tableView
    }()
    
    private var newMasterName: String?
    private var newMasterNumber: String?
    private var newMaster: Master?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNewMasterTableView()
        setupNavigationBar()
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
        let textField = UITextField()
        textField.delegate = self
        cell.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 14),
            textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])
        
        if indexPath.section == 0 {
            textField.placeholder = "Укажите имя сотрудника"
            textField.addTarget(self, action: #selector(nameTextFieldChanged(_:)), for: .editingChanged)
        } else {
            textField.placeholder = "Укажите телефон сотрудника"
            textField.addTarget(self, action: #selector(numberTextFieldChanged(_:)), for: .editingChanged)
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    
}


extension NewMasterViewController: UITextFieldDelegate {
    
    @objc private func nameTextFieldChanged (_ sender: UITextField) {
        newMasterName = sender.text
    }
    
    @objc private func numberTextFieldChanged (_ sender: UITextField) {
        newMasterNumber = sender.text
    }
    
    
}

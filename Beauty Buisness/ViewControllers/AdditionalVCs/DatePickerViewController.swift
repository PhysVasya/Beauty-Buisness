//
//  DatePickerViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 15.04.2022.
//

import Foundation
import UIKit


class DatePickerViewController: UIViewController {
    
    public let datePicker = UIDatePicker()
    public var datePickerDelegate: UIDatePickerDelegate?
    public var showingDate: Date? {
        didSet {
            datePicker.setDate(showingDate!, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = UserDefaults.standard.value(forKey: "FIRST-TIME-LAUNCH") as? Date
        
        view.addSubview(datePicker)

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.backgroundColor = .myBackgroundColor
        datePicker.addTarget(self, action: #selector(getDate(_:)), for: .valueChanged)
    }
    
    @objc private func getDate (_ from: UIDatePicker) {
        datePickerDelegate?.selectedDate(from)
    }
}


protocol UIDatePickerDelegate {
    
    func selectedDate (_ inPicker: UIDatePicker) 

}



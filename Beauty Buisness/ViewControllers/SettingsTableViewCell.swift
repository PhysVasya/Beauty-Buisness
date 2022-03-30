//
//  SettingsTableViewCell.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 29.03.2022.
//

import Foundation
import UIKit


class SettingsTableViewCell: UITableViewCell {
    
    
    
    private let topTimePicker: UIDatePicker = {
        let dp = UIDatePicker()
        let startHour = UserDefaults.standard.object(forKey: "STARTING-HOUR") as! Date
        dp.datePickerMode = .time
        dp.minuteInterval = 15
        dp.date = startHour
        return dp
    }()
    
    private let bottomTimePicker: UIDatePicker = {
        let endHour = UserDefaults.standard.object(forKey: "ENDING-HOUR") as! Date
        let dp = UIDatePicker()
        dp.date = endHour
        dp.datePickerMode = .time
        dp.minuteInterval = 15
        return dp
    }()
    
    static let identifier = "SettingsViewControllerCell"
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupCell () {
        
        let leftView = UILabel()
        
        
        let rightTopLabel = UILabel()
        rightTopLabel.text = "Начало: "
        let rightBottomLabel = UILabel()
        rightBottomLabel.text = "Конец: "
        
        leftView.text = "Время работы: "
        
        let topRightView = UIStackView(arrangedSubviews: [rightTopLabel, topTimePicker])
        topRightView.axis = .horizontal
        
        let bottomRightView = UIStackView(arrangedSubviews: [rightBottomLabel, bottomTimePicker])
        bottomRightView.axis = .horizontal
        
        let verticalStackView = UIStackView(arrangedSubviews: [topRightView, bottomRightView])
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        let horizontalStackView = UIStackView(arrangedSubviews: [leftView, verticalStackView])
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        
        leftView.translatesAutoresizingMaskIntoConstraints = false
        leftView.leadingAnchor.constraint(equalTo: horizontalStackView.leadingAnchor).isActive = true
        leftView.topAnchor.constraint(equalTo: horizontalStackView.topAnchor).isActive = true
        leftView.bottomAnchor.constraint(equalTo: horizontalStackView.bottomAnchor).isActive = true
        leftView.trailingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
        
        
        topRightView.translatesAutoresizingMaskIntoConstraints = false
        topRightView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
        topRightView.topAnchor.constraint(equalTo: verticalStackView.topAnchor).isActive = true
        topRightView.bottomAnchor.constraint(equalTo: bottomRightView.topAnchor).isActive = true
        topRightView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor).isActive = true
        
        bottomRightView.translatesAutoresizingMaskIntoConstraints = false
        bottomRightView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
        bottomRightView.topAnchor.constraint(equalTo: topRightView.bottomAnchor).isActive = true
        bottomRightView.bottomAnchor.constraint(equalTo: verticalStackView.bottomAnchor).isActive = true
        bottomRightView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor).isActive = true
        
        contentView.addSubview(horizontalStackView)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        
            
    }
    
    public func topTimePickerValueChanged (_ target: Any?, action: Selector) {
        topTimePicker.addTarget(target, action: action, for: .valueChanged)
    }
    
    public func bottomTimePickerValueChanged (_ target: Any?, action: Selector) {
        bottomTimePicker.addTarget(target, action: action, for: .valueChanged)
    }
    
}

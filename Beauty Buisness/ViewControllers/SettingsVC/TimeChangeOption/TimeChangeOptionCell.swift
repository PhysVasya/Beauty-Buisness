//
//  SettingsTableViewCell.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 29.03.2022.
//

import Foundation
import UIKit


class TimeChangeOptionCell: UITableViewCell {
    
    static let identifier = "SettingsViewControllerCell"
    
    private let topTimePicker: UIDatePicker = {
        let dp = UIDatePicker()
        let startHour = Int.startingHour
        let startingMinute = Int.startingMinute
        dp.datePickerMode = .time
        dp.minuteInterval = 15
        dp.date = Calendar.current.date(bySettingHour: startHour, minute: startingMinute, second: 0, of: Date.now)!
        return dp
    }()
    
    private let bottomTimePicker: UIDatePicker = {
        let endHour = Int.endingHour
        let endMinute = Int.endingMinute
        let dp = UIDatePicker()
        dp.date = Calendar.current.date(bySettingHour: endHour, minute: endMinute, second: 0, of: Date.now)!
        dp.datePickerMode = .time
        dp.minuteInterval = 15
        return dp
    }()
    
    
    
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
        topRightView.distribution = .fillEqually
        
        let bottomRightView = UIStackView(arrangedSubviews: [rightBottomLabel, bottomTimePicker])
        bottomRightView.axis = .horizontal
        bottomRightView.distribution = .fillEqually
        
        let verticalStackView = UIStackView(arrangedSubviews: [topRightView, bottomRightView])
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        let horizontalStackView = UIStackView(arrangedSubviews: [leftView, verticalStackView])
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        
        //Just adding constraints programmatically
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
    
    //PAY ATTENTION! A good way to pass values to different target. No need to specify self methods.
    public func topTimePickerValueChanged (_ target: Any?, action: Selector) {
        topTimePicker.addTarget(target, action: action, for: .valueChanged)
    }
    
    public func bottomTimePickerValueChanged (_ target: Any?, action: Selector) {
        bottomTimePicker.addTarget(target, action: action, for: .valueChanged)
    }
    
}

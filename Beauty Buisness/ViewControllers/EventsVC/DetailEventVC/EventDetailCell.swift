//
//  EventDetailCell.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 25.04.2022.
//

import Foundation
import UIKit

protocol EventDatePickerDelegate {
    func datePickerValueChanged (_ datePicker: UIDatePicker)
}

class EventDetailCell: UICollectionViewCell {
    
    
    public enum CellLabel: String {
        case event = "Запись"
        case procedure = "Процедура"
        case customer = "Клиент"
        case master = "Мастер"
        case note = "Заметки"
    }
    
    let label = UILabel()
    var delegate: EventDatePickerDelegate?
    
    
    public func configure (with text: CellLabel?, supplementary: UIView?) {
        
        label.text = text?.rawValue
        label.textColor = .myBackgroundColor
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        
        let HStack = UIStackView()
        if let supplementary = supplementary {
            HStack.addArrangedSubview(label)
            HStack.addArrangedSubview(supplementary)
        } else {
            HStack.addArrangedSubview(label)
        }
        HStack.alignment = .center
        HStack.distribution = .fillEqually
        HStack.axis = .horizontal
        
        contentView.backgroundColor = .myAccentColor
        contentView.layer.cornerRadius = contentView.frame.width / 25
        
        contentView.addSubview(HStack)
        HStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            HStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            HStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            HStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            HStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
        
    }
    
    public func configureTimeLabel (for event: EventDetailSection) {
        label.text = event.event?.day?.dateFormatted()
        label.textColor = .myBackgroundColor
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        
        let startLabel = UILabel()
        startLabel.text = "Начало"
        startLabel.textColor = .myBackgroundColor
        startLabel.font = .systemFont(ofSize: 16)
        let startEventPicker = UIDatePicker().startEventPicker(event: event)
        startEventPicker?.tag = 0
        startEventPicker?.addTarget(self, action: #selector(startEventHourChanged(_:)), for: .valueChanged)
        
        let endLabel = UILabel()
        endLabel.text = "Конец"
        endLabel.textColor = .myBackgroundColor
        endLabel.font = .systemFont(ofSize: 16)
        let endEventPicker = UIDatePicker().endEventPicker(event: event)
        endEventPicker?.tag = 1
        endEventPicker?.addTarget(self, action: #selector(endEventHourChanged(_:)), for: .valueChanged)
        
        let startStack = UIStackView(arrangedSubviews: [
            startLabel,
            startEventPicker!
        ])
        startStack.axis = .horizontal
        startStack.distribution = .fillEqually
        startStack.alignment = .center
        
        let endStack = UIStackView(arrangedSubviews: [
            endLabel,
            endEventPicker!
        ])
        endStack.axis = .horizontal
        endStack.distribution = .fillEqually
        endStack.alignment = .center
        
        let rightStackView = UIStackView(arrangedSubviews: [
            startStack,
            endStack
        ])
        rightStackView.axis = .vertical
        rightStackView.distribution = .fillEqually
        rightStackView.alignment = .center
        rightStackView.spacing = 5
                
        let HStack = UIStackView(arrangedSubviews: [label, rightStackView])
        HStack.alignment = .center
        HStack.distribution = .fillEqually
        HStack.axis = .horizontal
        
        contentView.backgroundColor = .myAccentColor
        contentView.layer.cornerRadius = contentView.frame.width / 25
        
        contentView.addSubview(HStack)
        HStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            HStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            HStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            HStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            HStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let subviews = contentView.subviews
        subviews.forEach({$0.removeFromSuperview()})
    }
}

extension EventDetailCell {
    @objc private func startEventHourChanged (_ sender: UIDatePicker) {
        sender.tag = 0
        delegate?.datePickerValueChanged(sender)
    }
    
    @objc private func endEventHourChanged (_ sender: UIDatePicker) {
        sender.tag = 1
        delegate?.datePickerValueChanged(sender)
    }
}

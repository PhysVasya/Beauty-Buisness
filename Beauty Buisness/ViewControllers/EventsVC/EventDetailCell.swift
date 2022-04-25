//
//  EventDetailCell.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 25.04.2022.
//

import Foundation
import UIKit

class EventDetailCell: UICollectionViewCell {
    
    
    public enum CellLabel: String {
        case event
        case procedure = "Процедура"
        case customer = "Клиент"
        case master = "Мастер"
        case note = "Заметки"
    }
    
    let label = UILabel()
    
    
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
        contentView.layer.cornerRadius = 25
     
        contentView.addSubview(HStack)
        HStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            HStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            HStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            HStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            HStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
    }
  
    override func prepareForReuse() {
        super.prepareForReuse()
        let subviews = contentView.subviews
        subviews.forEach({$0.removeFromSuperview()})
    }
}

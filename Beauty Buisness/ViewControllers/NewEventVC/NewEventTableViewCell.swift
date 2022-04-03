//
//  NewEventCell.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 03.04.2022.
//

import Foundation
import UIKit


class NewEventTableViewCell: UITableViewCell {
    
    static let identifier = "NewEventTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configure (with firstView: UIView, secondView: UIView) {
        
        
        let stackView = UIStackView(arrangedSubviews: [firstView, secondView])
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.frame = contentView.bounds
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])  
        
    }
}

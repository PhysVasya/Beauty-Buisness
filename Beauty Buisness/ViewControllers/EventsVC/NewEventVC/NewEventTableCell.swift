//
//  NewEventCell.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 03.04.2022.
//

import Foundation
import UIKit


class NewEventTableCell: UITableViewCell {
    
    static let identifier = "NewEventTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public var newText: ((String) -> Void)?
    
    public func configure (with view: UIView, secondView: UIView? = nil) {
        
        if let secondView = secondView {
            let stackView = UIStackView(arrangedSubviews: [view, secondView])
            stackView.alignment = .center
            stackView.axis = .horizontal
            stackView.frame = contentView.bounds
            contentView.addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            stackView.isLayoutMarginsRelativeArrangement = true
            
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])

        } else {
            let stackView = UIStackView(arrangedSubviews: [view])
            stackView.alignment = .center
            stackView.axis = .horizontal
            stackView.frame = contentView.bounds
            contentView.addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            stackView.isLayoutMarginsRelativeArrangement = true
            
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])  
        }
       
        
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let subviews = contentView.subviews
        if !subviews.isEmpty {
            subviews.forEach { view in
                view.removeFromSuperview()
            }
        }
        
  
    }
}

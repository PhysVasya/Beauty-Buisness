//
//  HeaderView.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 17.04.2022.
//

import Foundation
import UIKit


class HeaderView: UICollectionReusableView {
    
    static let identifier = "headerViewIdentifier"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    

    func configure () {
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        let inset = CGFloat(5)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        label.textAlignment = .center
        label.textColor = .myBackgroundColor
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.backgroundColor = .myAccentColor
    }
    
}

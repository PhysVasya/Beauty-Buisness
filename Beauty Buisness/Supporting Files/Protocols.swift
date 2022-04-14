//
//  Protocols.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 14.04.2022.
//

import Foundation
import UIKit


protocol UITextFieldDelegateSelection: UITextFieldDelegate {
    
    func didSelectTextField(_ textField: UITextField, at indexPath: IndexPath)
    
    func didDeselectTextField(_ textField: UITextField, at indexPath: IndexPath)
    
    
}

//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Gage Condon on 12/4/21.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}

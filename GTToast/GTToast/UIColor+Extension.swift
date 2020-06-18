//
//  UIColor+Extension.swift
//  GTToast
//
//  Created by Gabriel Targon on 07/10/19.
//  Copyright © 2019 Gabriel Targon. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}

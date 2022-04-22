//
//  UIView+Extension.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 22/4/2022.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return borderWidth }
        set {
            self.layer.borderWidth = newValue
        }
    }
}

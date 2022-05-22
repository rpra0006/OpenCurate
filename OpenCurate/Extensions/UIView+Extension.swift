//
//  UIView+Extension.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 22/4/2022.
//

import Foundation
import UIKit

extension UIView {
    
    // Extension for UIButton to allow rounded borders
    // Reference: https://stackoverflow.com/questions/26961274/how-can-i-make-a-button-have-a-rounded-border-in-swift
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

//
//  UIImageView+enableZoom.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 5/5/2022.
//

import Foundation
import UIKit

extension UIImageView {
    // Enable zooming for UIImages by calling enableZoom().
    // Reference: John Lima https://stackoverflow.com/questions/30014241/uiimageview-pinch-zoom-swift
    
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
      }

    @objc
      private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
      }

}

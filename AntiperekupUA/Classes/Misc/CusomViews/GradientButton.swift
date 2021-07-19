//
//  GradientButton.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 07.11.2020.
//

import UIKit

class GradientButton: UIButton {
    var defaultColors = [CGColor]() {
        didSet {
            gradientLayer.colors = defaultColors
        }
    }
    var highlightedColors = [CGColor]()
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard isHighlighted != oldValue, !highlightedColors.isEmpty else {
                return
            }
            
            gradientLayer.colors = isHighlighted ? highlightedColors : defaultColors
        }
    }
}

//
//  UIColorExtension.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 07.11.2020.
//

import UIKit

extension UIColor {
    convenience init(integralRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
    
    func navigationShadow() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

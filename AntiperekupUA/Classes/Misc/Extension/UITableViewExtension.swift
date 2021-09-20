//
//  UITableViewExtension.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//

import UIKit

extension UITableViewCell {
    func round(corners: UIRectCorner, radius: CGFloat) {
        let mask = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.frame = bounds
        shape.path = mask.cgPath
        layer.mask = shape
    }
}

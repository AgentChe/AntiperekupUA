//
//  UITableViewExtension.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//

import UIKit

protocol CornerCellContainer: UITableViewCell {
    var containerView: UIView { get }
}

extension CornerCellContainer {
    func round(corners: UIRectCorner, radius: CGFloat) {
        let mask = UIBezierPath(roundedRect: containerView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.frame = containerView.bounds
        shape.path = mask.cgPath
        containerView.layer.mask = shape
    }
}

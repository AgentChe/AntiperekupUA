//
//  UITableViewExtension.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//

import UIKit

protocol CornerCellContainer: UITableViewCell {
    var containerView: UIView { get }
    var padding: CGFloat { get }
}

extension CornerCellContainer {
    var padding: CGFloat {
        16.scale
    }
}

extension CornerCellContainer {
    func round(corners: UIRectCorner, radius: CGFloat) {
        let bounds = CGRect(origin: .zero, size: .init(width: contentView.bounds.width - padding * 2, height: contentView.bounds.height))
        let mask = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.frame = bounds
        shape.path = mask.cgPath
        containerView.layer.mask = shape
    }
}

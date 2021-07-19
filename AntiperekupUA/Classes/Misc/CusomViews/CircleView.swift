//
//  CircleView.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 07.11.2020.
//

import UIKit

class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = max(frame.width, frame.height) / 2
    }
}

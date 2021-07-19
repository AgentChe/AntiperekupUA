//
//  Toast.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 07.01.2021.
//

import UIKit
import NotificationBannerSwift

final class Toast {}

// MARK: API
extension Toast {
    static func notify(with text: String, style: BannerStyle) {
//        let attributedText = text
//            .attributed(with: TextAttributes()
//                            .font(Fonts.Poppins.bold(size: 17.scale))
//                            .textColor(UIColor.black)
//                            .textAlignment(.center))
//
//        NotificationBanner(attributedTitle: attributedText, style: style).show()
    }
    
    static func notify(with attributedText: NSAttributedString, style: BannerStyle) {
//        NotificationBanner(attributedTitle: attributedText, style: style).show()
    }
}

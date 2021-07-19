//
//  Device.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 07.11.2020.
//

import UIKit

enum ScreenSize {
    static let bounds: CGRect = (UIScreen.main.bounds)
    static let width: CGFloat = (bounds.width)
    static let height: CGFloat = (bounds.height)
    static let maxLength: CGFloat = (max(width, height))
    static let minLength: CGFloat = (min(width, height))
    
    static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    static let isIphone = UIDevice.current.userInterfaceIdiom == .phone
    static let isRetina = (UIScreen.main.scale >= 2.0)
    static let isIphoneX = (isIphone && maxLength == 812.0)
    static let isIphoneXMax = (isIphone && maxLength == 896.0)
    static let isIphoneXFamily = (isIphone && maxLength / minLength > 2.0)
}

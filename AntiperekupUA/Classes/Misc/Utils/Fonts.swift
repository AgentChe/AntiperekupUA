//
//  Fonts.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 07.11.2020.
//

import UIKit

struct Fonts {
    struct SFProDisplay {
        static func font(weight: Weight, size: CGFloat) -> UIFont {
            UIFont(name: weight.fontName, size: size)!
        }
        
        enum Weight {
            case W400
            case W500
            case W600
            case W700
            
            var fontName: String {
                switch self {
                case .W400:
                    return "SFProDisplay-Regular"
                case .W500:
                    return "SFProDisplay-Medium"
                case .W600:
                    return "SFProDisplay-Semibold"
                case .W700:
                    return "SFProDisplay-Bold"
                }
            }
        }
    }
    
    struct SFProText {
        static func font(weight: Weight, size: CGFloat) -> UIFont {
            UIFont(name: weight.fontName, size: size)!
        }
        
        enum Weight {
            case W400
            case W500
            case W600
            case W700
            
            var fontName: String {
                switch self {
                case .W400:
                    return "SFProText-Regular"
                case .W500:
                    return "SFProText-Medium"
                case .W600:
                    return "SFProText-Semibold"
                case .W700:
                    return "SFProText-Bold"
                }
            }
        }
    }
    
    struct Oswald {
        static func font(weight: Weight, size: CGFloat) -> UIFont {
            UIFont(name: weight.fontName, size: size)!
        }
        
        enum Weight {
            case W400
            
            var fontName: String {
                switch self {
                case .W400:
                    return "Oswald-Regular"
                }
            }
        }
    }
}

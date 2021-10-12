//
//  SidebarAnimationDelegate.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.10.2021.
//

import UIKit

final class SidebarAnimationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidebarAnimation(duration: 0.5, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidebarAnimation(duration: 0.5, animationType: .dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SidebarPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
}


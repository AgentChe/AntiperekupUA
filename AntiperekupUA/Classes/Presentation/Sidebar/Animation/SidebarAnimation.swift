//
//  SidebarAnimation.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.10.2021.
//

import UIKit

class SidebarAnimation: NSObject {

    private let duration: Double
    private let animationType: AnimationType
    
    enum AnimationType {
        case present
        case dismiss
    }
    
    init(duration: Double, animationType: AnimationType) {
        self.duration = duration
        self.animationType = animationType
    }
}

extension SidebarAnimation: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch animationType {
        case .present:
            presentAnimation(transitionContext: transitionContext)
        case .dismiss:
            dismissAnimation(transitionContext: transitionContext)
        }
    }
    
    private func presentAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame = finalFrame
        containerView.addSubview(toViewController.view)
        
        guard let snapshot = toViewController.view.snapshotView(afterScreenUpdates: true) else { return }
        
        snapshot.frame = finalFrame
        containerView.addSubview(snapshot)
        toViewController.view.isHidden = true
        snapshot.frame.origin.x = -finalFrame.width
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                snapshot.frame.origin.x = 0
            },
            completion: { _ in
                toViewController.view.isHidden = false
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
    
    private func dismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                fromView.frame.origin.x = -fromView.frame.width
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

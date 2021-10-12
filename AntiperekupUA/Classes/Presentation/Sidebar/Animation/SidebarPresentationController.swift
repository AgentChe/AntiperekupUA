//
//  SidebarPresentationController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.10.2021.
//

import UIKit

class SidebarPresentationController: UIPresentationController {
    
    private let dimmingView: UIView!
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dimmingView.alpha = 0
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let recognizer = UITapGestureRecognizer(
          target: self,
          action: #selector(handleTap(recognizer:))
        )
        
        dimmingView.addGestureRecognizer(recognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        
        var frame = containerView.bounds
        frame.size.width = 314.scale
        frame.size.height = containerView.bounds.height
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        guard let dimmingView = dimmingView, let containerView = containerView else {
            return
        }
        
        containerView.insertSubview(dimmingView, at: 0)
        
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
          }

          coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
          })
    }
    
    override func dismissalTransitionWillBegin() {
      guard let coordinator = presentedViewController.transitionCoordinator else {
        dimmingView.alpha = 0.0
        return
      }

      coordinator.animate(alongsideTransition: { _ in
        self.dimmingView.alpha = 0.0
      })
    }
    
    override func containerViewWillLayoutSubviews() {
      presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
            
            guard let containerView = containerView else {
                return
            }
            
            containerView.setNeedsLayout()
    }
    
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
}


//
//  Copyright © 2018 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

class ModalPresentationController: UIPresentationController {
    // Presentation wrapper view
    private var presentationWrappingView: UIView?
    public let cornerRadius: CGFloat = 14
    public let shadowOpacity: Float = 0.5
    public let shadowRadius: CGFloat = 15
    public let shadowOffset = CGSize(width: 0, height: 2)
    
    // Dimming view
    private var dimmingView: UIView?
    public let dimmingViewAlpha: CGFloat = 0.5
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
    }
    
    @objc func close() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Adaptive Layout
extension ModalPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerViewBounds = containerView?.bounds else { return .zero }
        let presentedViewContentSize = size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerViewBounds.size)
        
        let additionalTopInset: CGFloat = 10
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let x: CGFloat = 0
        let y: CGFloat = containerViewBounds.minY + statusBarHeight + additionalTopInset
        let width = presentedViewContentSize.width
        let height = presentedViewContentSize.height
        return CGRect(x: x, y: y, width: width, height: height - y)
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        if let containerViewController = container as? UIViewController,
            containerViewController == presentedViewController {
            containerView?.setNeedsLayout()
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let containerViewController = container as? UIViewController,
            containerViewController == presentedViewController {
            return containerViewController.preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        dimmingView?.frame = containerView!.bounds
        presentationWrappingView?.frame = frameOfPresentedViewInContainerView
    }
}

// MARK: - Presentation
extension ModalPresentationController {
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView,
              let coordinator = presentingViewController.transitionCoordinator else { return }
        
        // [From Apple sample code]
        //
        // Wrap the presented view controller's view in an intermediate hierarchy
        // that applies a shadow and rounded corners to the top-left and top-right
        // edges.  The final effect is built using three intermediate views.
        //
        // presentationWrapperView              <- shadow
        //   |- presentationRoundedCornerView   <- rounded corners (masksToBounds)
        //        |- presentedViewControllerWrapperView
        //             |- presentedViewControllerView (presentedViewController.view)
        //
        do {
            let presentationWrapperView = UIView(frame: frameOfPresentedViewInContainerView)
            presentationWrapperView.layer.shadowOpacity = shadowOpacity
            presentationWrapperView.layer.shadowRadius = shadowRadius
            presentationWrapperView.layer.shadowOffset = shadowOffset
            
            let presentationRoundedCornerView = UIView(frame: UIEdgeInsetsInsetRect(presentationWrapperView.bounds, UIEdgeInsets(top: 0, left: 0, bottom: -cornerRadius, right: 0)))
            presentationRoundedCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            presentationRoundedCornerView.layer.cornerRadius = cornerRadius
            presentationRoundedCornerView.layer.masksToBounds = true
            
            let presentedViewControllerWrapperView = UIView(frame: UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, UIEdgeInsets(top: 0, left: 0, bottom: cornerRadius, right: 0)))
            presentationRoundedCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            presentationRoundedCornerView.frame = presentedViewControllerWrapperView.bounds
            
            let presentedViewControllerView = super.presentedView
            presentedViewControllerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            presentedViewControllerView?.frame = presentedViewControllerWrapperView.bounds
            
            presentedViewControllerWrapperView.addSubview(presentedViewControllerView!)
            presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
            presentationWrapperView.addSubview(presentationRoundedCornerView)
            presentationWrappingView = presentationWrapperView
        }
        
        // Add a dimming view to the background
        do {
            // Create the dimming view
            dimmingView = UIView(frame: presentedViewController.view.frame)
            dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(dimmingViewAlpha)
            containerView.addSubview(dimmingView!)
            
            // Fade the dimming view in
            dimmingView?.alpha = 0
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.dimmingView?.alpha = 1
            }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            presentationWrappingView = nil
            dimmingView = nil
        }
    }
    
    override var presentedView: UIView? {
        // Return the wrapping view that adds the shadow and corner radius
        return presentationWrappingView
    }
}

// MARK: - Dismissal
extension ModalPresentationController {
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.dimmingView?.alpha = 0
        }, completion: { (done) in
            self.dimmingView?.removeFromSuperview()
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentationWrappingView = nil
            dimmingView = nil
        }
    }
}

// MARK: - Animated Transitioning
extension ModalPresentationController: UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let isPresenting = (fromViewController == presentingViewController)
        if isPresenting {
            animatePresentation(using: transitionContext, from: fromViewController, to: toViewController)
        } else {
            animateDismissal(using: transitionContext, from: fromViewController, to: toViewController)
        }
    }
    
    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning, from fromViewController: UIViewController, to toViewController: UIViewController) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let duration = transitionDuration(using: transitionContext)
        
        containerView?.addSubview(toView)
        
        toView.transform = CGAffineTransform(translationX: 0, y: finalFrame.origin.y + finalFrame.height)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
            toView.transform = .identity
            
        }) { (completed) -> Void in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
    
    func animateDismissal(using transitionContext: UIViewControllerContextTransitioning, from fromViewController: UIViewController, to toViewController: UIViewController) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let initialFrame = transitionContext.initialFrame(for: fromViewController)
        let duration = transitionDuration(using: transitionContext)
        
        fromView.transform = .identity
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
            fromView.transform = CGAffineTransform(translationX: 0, y: initialFrame.size.height)
            
        }) { (completed) in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}

// MARK: - Transitioning Delegate
extension ModalPresentationController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

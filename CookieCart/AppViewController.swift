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
import CoreLocation
import AVFoundation
import SquareReaderSDK

final class AppViewController: UIViewController {
    var currentViewController: UIViewController? {
        return childViewControllers.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The user might open the Settings app to change their permissions.
        // When they return, update the buttons to reflect their preferences.
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreen), name: .UIApplicationWillEnterForeground, object: nil)
        
        // Authorize Reader SDK when the view first shows
        let authorizationViewController = AuthorizationViewController()
        authorizationViewController.delegate = self
        show(viewController: authorizationViewController)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.isPhone ? .portrait : .all
    }

    @objc internal func updateScreen() {
        let permissionsGranted = PermissionsViewController.areRequiredPermissionsGranted
        
        if !permissionsGranted {
            // Permissions are required, so modally present the permissions view controller
            let permissionsViewController = PermissionsViewController()
            let customTransitioningDelegate: UIViewControllerTransitioningDelegate = {
                if UIDevice.current.isPhone {
                    return ModalPresentationController(presentedViewController: permissionsViewController, presenting: self)
                } else {
                    return CardPresentationController(presentedViewController: permissionsViewController, presenting: self)
                }
            }()
            permissionsViewController.delegate = self
            permissionsViewController.transitioningDelegate = customTransitioningDelegate
            present(permissionsViewController, animated: true, completion: nil)
            
        } else {
            let payViewController = PayViewController()
            show(viewController: payViewController)
        }
    }
}

extension AppViewController: AuthorizationViewControllerDelegate {
    func authorizationViewControllerDidCompleteAuthorization(_ authorizationViewController: AuthorizationViewController) {
        updateScreen()
    }
}

extension AppViewController: PermissionsViewControllerDelegate {
    func permissionsViewControllerDidObtainRequiredPermissions(_ permissionsViewController: PermissionsViewController) {
        dismiss(animated: true, completion: nil)
        updateScreen()
    }
}

// MARK: - Transitions
extension AppViewController {
    /// Show the provided view controller
    public func show(viewController newViewController: UIViewController) {
        // If we're already displaying a view controller, transition to the new one.
        if let oldViewController = currentViewController,
            type(of: newViewController) != type(of: oldViewController) {
            transition(from: oldViewController, to: newViewController)
            
        } else if currentViewController == nil {
            // Add the view controller as a child view controller
            addChildViewController(newViewController)
            newViewController.view.frame = view.bounds
            view.addSubview(newViewController.view)
            newViewController.didMove(toParentViewController: self)
        }
    }
    
    /// Transition from one child view controller to another
    private func transition(from fromViewController: UIViewController, to toViewController: UIViewController) {
        // Remove any leftover child view controllers
        childViewControllers.forEach { (childViewController) in
            if childViewController != fromViewController {
                childViewController.willMove(toParentViewController: nil)
                childViewController.view.removeFromSuperview()
                childViewController.removeFromParentViewController()
            }
        }
        
        addChildViewController(toViewController)
        fromViewController.willMove(toParentViewController: nil)
    
        toViewController.view.alpha = 0
        toViewController.view.layoutIfNeeded()
        
        let animations = {
            fromViewController.view.alpha = 0
            toViewController.view.alpha = 1
        }
        
        let completion: (Bool) -> Void = { _ in
            fromViewController.view.removeFromSuperview()
            fromViewController.removeFromParentViewController()
            toViewController.didMove(toParentViewController: self)
        }
        
        transition(from: fromViewController,
                   to: toViewController,
                   duration: 0.25,
                   options: [],
                   animations: animations,
                   completion: completion)
    }
}


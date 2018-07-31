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
import SquareReaderSDK

protocol AuthorizationViewControllerDelegate: class {
    func authorizationViewControllerDidCompleteAuthorization(_ authorizationViewController: AuthorizationViewController)
}

/**
 * Authorize Reader SDK using a hardcoded mobile authorization code.
 */
class AuthorizationViewController: UIViewController {
    weak var delegate: AuthorizationViewControllerDelegate?
    private lazy var loadingIndicator = makeLoadingIndicator()
    
    /*****
     Step 3️⃣: Authorize Reader SDK
    *****/
    func authorizeReaderSDK() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the 🍪 loading indicator and constraints
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start animating the loading indicator
        loadingIndicator.startAnimating()
        
        // Authorize Reader SDK
        authorizeReaderSDK()
    }
    
    private func makeLoadingIndicator() -> CookieLoadingIndicator {
        // Make a 🍪 loading indicator
        let loadingIndicator = CookieLoadingIndicator()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.delegate = self
        return loadingIndicator
    }
}

extension AuthorizationViewController: CookieLoadingIndicatorDelegate {
    func cookieLoadingIndicatorDidCompleteCycle(_ cookieLoadingIndicator: CookieLoadingIndicator) {
        // Crash if the placeholder code for step 3 hasn't been filled out
        if !(SQRDReaderSDK.shared.isAuthorizationInProgress || SQRDReaderSDK.shared.isAuthorized) {
            fatalError("Make sure to fill out the placeholder for Step 3️⃣ at the top of this file before running the app!")
        }
        
        // If we're authorized, notify our delegate
        if SQRDReaderSDK.shared.isAuthorized {
            delegate?.authorizationViewControllerDidCompleteAuthorization(self)
            
            // Stop animating the loading indicator
            cookieLoadingIndicator.stopAnimating()
        }
    }
}

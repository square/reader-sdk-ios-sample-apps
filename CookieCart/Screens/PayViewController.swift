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

/**
 * Start using Square Reader SDK!
 */
final class PayViewController: UIViewController {
    private lazy var tinyCookieImageView = UIImageView(image: #imageLiteral(resourceName: "cookie-1"))
    private lazy var giantCookieView = RandomImageCenteringView(image: #imageLiteral(resourceName: "giant-cookie"))
    private lazy var itemPickerView = makeItemPickerView()
    private lazy var readerSettingsButton = makeReaderSettingsButton()
    
    /*****
     Step 4️⃣: Show the Reader Settings screen
     *****/
    @objc private func settingsButtonTapped() {
        
    }
    
    /*****
     Step 5️⃣: Start Checkout
     *****/
    @objc private func charge(amount: Int, note: String) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tinyCookieImageView.translatesAutoresizingMaskIntoConstraints = false
        giantCookieView.translatesAutoresizingMaskIntoConstraints = false
        readerSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        itemPickerView.translatesAutoresizingMaskIntoConstraints = false
        itemPickerView.delegate = self
        
        view.addSubview(tinyCookieImageView)
        view.addSubview(giantCookieView)
        view.addSubview(readerSettingsButton)
        view.addSubview(itemPickerView)
        
        if UIDevice.current.isPhone {
            additionalSafeAreaInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            NSLayoutConstraint.activate([
                itemPickerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
                itemPickerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            ])
        } else {
            additionalSafeAreaInsets = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
            NSLayoutConstraint.activate([
                itemPickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                itemPickerView.widthAnchor.constraint(equalToConstant: 400)
            ])
        }
        
        NSLayoutConstraint.activate([
            tinyCookieImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            tinyCookieImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tinyCookieImageView.widthAnchor.constraint(equalToConstant: 64),
            tinyCookieImageView.heightAnchor.constraint(equalTo: tinyCookieImageView.widthAnchor),
            
            readerSettingsButton.centerYAnchor.constraint(equalTo: tinyCookieImageView.centerYAnchor),
            readerSettingsButton.heightAnchor.constraint(equalTo: readerSettingsButton.widthAnchor),
            readerSettingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            readerSettingsButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            giantCookieView.topAnchor.constraint(equalTo: tinyCookieImageView.bottomAnchor),
            giantCookieView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            giantCookieView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            giantCookieView.bottomAnchor.constraint(equalTo: itemPickerView.topAnchor),

            itemPickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            itemPickerView.heightAnchor.constraint(equalToConstant: 235)
        ])
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.isPhone ? .portrait : .all
    }
}

// MARK: - UI
extension PayViewController {
    private func makeItemPickerView() -> ItemPickerView {
        guard let location = SQRDReaderSDK.shared.authorizedLocation else {
            fatalError("Square Reader SDK must be authorized before using ItemPickerView.")
        }
        let cookiePrice = 150 // $1.50 USD
        return ItemPickerView(costPerItem: cookiePrice, location: location)
    }
    
    private func makeReaderSettingsButton() -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
        return button
    }
}

// MARK: - ItemPickerViewDelegate
extension PayViewController: ItemPickerViewDelegate {
    func itemPickerViewDidAddItem(_ itemPickerView: ItemPickerView) {
        giantCookieView.addImageView()
    }
    
    func itemPickerViewDidSubtractItem(_ itemPickerView: ItemPickerView) {
        giantCookieView.removeLastImageView()
    }
    
    func itemPickerView(_ itemPickerView: ItemPickerView, didRequestCheckoutWith numberOfItems: Int, totalCost: Int) {
        charge(amount: totalCost, note: "\(numberOfItems)  🍪")
    }
}

// MARK: - SQRDCheckoutControllerDelegate
extension PayViewController: SQRDCheckoutControllerDelegate {
    func checkoutController(_ checkoutController: SQRDCheckoutController, didFinishCheckoutWith result: SQRDCheckoutResult) {
        // Checkout finished, print the result.
        print(result)
        
        // Reset view state
        itemPickerView.reset()
        giantCookieView.removeAllAddedImageViews()
        
        showAlert(title: "Successfully Charged", message: "See the Xcode console for transaction details. You can refund transactions from your Square Dashboard.")
    }
    
    func checkoutController(_ checkoutController: SQRDCheckoutController, didFailWith error: Error) {
        /**************************************************************************************************
         * The Checkout controller failed due to an error.
         *
         * Errors from Square Reader SDK always have a `localizedDescription` that is appropriate for displaying to users.
         * Use the values of `userInfo[SQRDErrorDebugCodeKey]` and `userInfo[SQRDErrorDebugMessageKey]` (which are always
         * set for Reader SDK errors) for more information about the underlying issue and how to recover from it in your app.
         **************************************************************************************************/
        
        if let checkoutError = error as? SQRDCheckoutControllerError,
            let debugCode = checkoutError.userInfo[SQRDErrorDebugCodeKey] as? String,
            let debugMessage = checkoutError.userInfo[SQRDErrorDebugMessageKey] as? String {
            
            print(debugCode)
            print(debugMessage)
            showAlert(title: "Checkout Error", message: checkoutError.localizedDescription)
        }
    }
    
    func checkoutControllerDidCancel(_ checkoutController: SQRDCheckoutController) {
        print("Checkout cancelled.")
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - SQRDReaderSettingsControllerDelegate
extension PayViewController: SQRDReaderSettingsControllerDelegate {
    func readerSettingsControllerDidPresent(_ readerSettingsController: SQRDReaderSettingsController) {
        print("The Reader Settings controller did present.")
    }
    
    func readerSettingsController(_ readerSettingsController: SQRDReaderSettingsController, didFailToPresentWith error: Error) {
        /**************************************************************************************************
         * The Reader Settings controller failed due to an error.
         *
         * Errors from Square Reader SDK always have a `localizedDescription` that is appropriate for displaying to users.
         * Use the values of `userInfo[SQRDErrorDebugCodeKey]` and `userInfo[SQRDErrorDebugMessageKey]` (which are always
         * set for Reader SDK errors) for more information about the underlying issue and how to recover from it in your app.
         **************************************************************************************************/
        
        if let readerSettingsError = error as? SQRDReaderSettingsControllerError,
            let debugCode = readerSettingsError.userInfo[SQRDErrorDebugCodeKey] as? String,
            let debugMessage = readerSettingsError.userInfo[SQRDErrorDebugMessageKey] as? String {
                
            print(debugCode)
            print(debugMessage)
            fatalError(error.localizedDescription)
        }
    }
}

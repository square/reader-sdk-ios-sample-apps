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

protocol PermissionsViewControllerDelegate: class {
    /// Called when the user grants all required permissions
    func permissionsViewControllerDidObtainRequiredPermissions(_ permissionsViewController: PermissionsViewController)
}

/**
 * Request system permissions from the user.
 *
 * Square requires microphone access to swipe credit cards using the headphone jack
 * on your device and location (while your app is in use) to protect buyers and sellers.
 */
final class PermissionsViewController: UIViewController {
    public weak var delegate: PermissionsViewControllerDelegate?
    
    public lazy var buttonsStackView = makeStackView()
    public lazy var titleLabel = makeTitleLabel()
    public lazy var centeredStackView = makeCenteredStackView()
    public lazy var handshakeView = makeHandshakeView()
    public lazy var subtitleLabel = makeSubtitleLabel()
    
    private lazy var microphoneButton = Button(title: "Enable Microphone Access", target: self, selector: #selector(microphoneButtonTapped))
    private lazy var locationButton = Button(title: "Enable Location Access", target: self, selector: #selector(locationButtonTapped))
    private lazy var locationManager = CLLocationManager()
    
    /// Returns true if all required permissions have been granted by the user.
    static var areRequiredPermissionsGranted: Bool {
        let locationStatus = CLLocationManager.authorizationStatus()
        let isLocationAccessGranted = (locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways)
        let isMicrophoneAccessGranted = AVAudioSession.sharedInstance().recordPermission() == .granted
        return (isLocationAccessGranted && isMicrophoneAccessGranted)
    }
    
    // Only support portrait orientation on iPhone
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.isPhone ? .portrait : .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up insets for the view
        additionalSafeAreaInsets = UIEdgeInsets(top: 18, left: 24, bottom: 24, right: 24)
        
        // Set the size of the view
        if UIDevice.current.userInterfaceIdiom == .phone {
            preferredContentSize = UIScreen.main.bounds.size
        } else {
            preferredContentSize = CGSize(width: 400, height: 628)
        }
        
        // Add labels and centered stack view
        view.addSubview(titleLabel)
        view.addSubview(centeredStackView)
        
        // Set background color and add the buttons stack view
        view.backgroundColor = .white
        view.addSubview(buttonsStackView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            centeredStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centeredStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -75),
            centeredStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        ])
        
        // Add the microphone and location buttons
        [microphoneButton, locationButton].forEach(buttonsStackView.addArrangedSubview)
        updateMicrophoneButton()
        updateLocationButton()

        // The user might open the Settings app to change their permissions.
        // When they return, update the buttons to reflect their preferences.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateMicrophoneButton),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLocationButton),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    // MARK: - Private Methods
    private func openSettings() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - UI
extension PermissionsViewController {
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makeTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = #colorLiteral(red: 0.2, green: 0.231372549, blue: 0.262745098, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Permissions"
        return titleLabel
    }
    
    private func makeCenteredStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(handshakeView)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 32
        return stackView
    }
    
    private func makeHandshakeView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "hand-shake")
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func makeSubtitleLabel() -> UILabel {
        let subtitleLabel = UILabel()
        
        // Configure label
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.numberOfLines = 3
        subtitleLabel.textColor = #colorLiteral(red: 0.2, green: 0.231372549, blue: 0.262745098, alpha: 1)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set text of the label
        let prompt = "\"Cookie Cart\" needs the following permissions granted in order to work properly with Square Reader SDK."
        let paragraphStyle = NSMutableParagraphStyle()
        let attributedPrompt = NSMutableAttributedString(string: prompt)
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5
        attributedPrompt.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, prompt.count))
        subtitleLabel.attributedText = attributedPrompt
        
        return subtitleLabel
    }
}

// MARK: - Microphone Access
extension PermissionsViewController {
    @objc private func microphoneButtonTapped() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case .denied:
            openSettings()
        case .undetermined:
            requestMicrophoneAccess()
        case .granted:
            return
        }
    }
    
    private func requestMicrophoneAccess() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async {
                self.updateMicrophoneButton()
                
                if PermissionsViewController.areRequiredPermissionsGranted {
                    self.delegate?.permissionsViewControllerDidObtainRequiredPermissions(self)
                }
            }
        }
    }
    
    @objc private func updateMicrophoneButton() {
        let title: String
        let isEnabled: Bool
        
        switch AVAudioSession.sharedInstance().recordPermission() {
        case .denied:
            title = "Enable Microphone in Settings"
            isEnabled = true
        case .granted:
            title = "Microphone Enabled"
            isEnabled = false
        case .undetermined:
            title = "Enable Microphone Access"
            isEnabled = true
        }
        
        microphoneButton.setTitle(title, for: [])
        microphoneButton.isEnabled = isEnabled
    }
}

// MARK: - Location Access
extension PermissionsViewController: CLLocationManagerDelegate {
    @objc private func locationButtonTapped() {
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            openSettings()
        case .notDetermined:
            requestLocationAccess()
        case .authorizedAlways, .authorizedWhenInUse:
            return
        }
    }
    
    private func requestLocationAccess() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateLocationButton()
        
        if PermissionsViewController.areRequiredPermissionsGranted {
            delegate?.permissionsViewControllerDidObtainRequiredPermissions(self)
        }
    }
    
    @objc private func updateLocationButton() {
        let title: String
        let isEnabled: Bool
        
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            title = "Enable Location in Settings"
            isEnabled = true
        case .authorizedAlways, .authorizedWhenInUse:
            title = "Location Granted"
            isEnabled = false
        case .notDetermined:
            title = "Enable Location Access"
            isEnabled = true
        }
        
        locationButton.setTitle(title, for: [])
        locationButton.isEnabled = isEnabled
    }
}

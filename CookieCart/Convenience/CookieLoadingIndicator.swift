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

protocol CookieLoadingIndicatorDelegate: class {
    func cookieLoadingIndicatorDidCompleteCycle(_ cookieLoadingIndicator: CookieLoadingIndicator)
}

// A 🍪 crumbling loading indicator
class CookieLoadingIndicator: UIView {
    public var delegate: CookieLoadingIndicatorDelegate?
    
    private lazy var imageView = makeImageView()
    private var timer: Timer?
    
    private static let images = [#imageLiteral(resourceName: "cookie-0"), #imageLiteral(resourceName: "cookie-1"), #imageLiteral(resourceName: "cookie-2"), #imageLiteral(resourceName: "cookie-3"), #imageLiteral(resourceName: "cookie-4")]
    private var currentImage = CookieLoadingIndicator.images.first!
    
    init() {
        super.init(frame: .zero)
        
        // Add an image view and constraints
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startAnimating() {
        // Start a new timer that progresses through each cookie image
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (_) in
            // Find the current image index and increment it
            let images = CookieLoadingIndicator.images
            var currentCookieImageIndex = images.index(of: self.currentImage)!
            currentCookieImageIndex += 1
            
            // If we've reached the last image, go back to the beginning
            if currentCookieImageIndex == images.count {
                currentCookieImageIndex = 0
                
                // Tell our delegate that the 🍪 was eaten
                self.delegate?.cookieLoadingIndicatorDidCompleteCycle(self)
            }
            
            // Set the new image
            self.currentImage = images[currentCookieImageIndex]
            self.imageView.image = self.currentImage
        })
    }
    
    func stopAnimating() {
        // Invalidate the timer and set it to nil
        timer?.invalidate()
        timer = nil
    }
    
    private func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = currentImage
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}

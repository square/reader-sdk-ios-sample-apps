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

class RandomImageCenteringView: UIView {
    private var image: UIImage
    private var imageViews = [UIImageView]()
    
    init(image: UIImage) {
        self.image = image
        
        super.init(frame: .zero)
        
        addImageView(centerRelativeMultiplierX: 1, centerRelativeMultiplierY: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    public func addImageView() {
        let insetPercentage: CGFloat = UIDevice.current.isPhone ? 0.5 : 0.3
        let randomXMultiplier = generateRandomNumber(min: insetPercentage, max: 2 - insetPercentage)
        let randomYMultiplier = generateRandomNumber(min: insetPercentage, max: 2 - insetPercentage)
        let randomScale = generateRandomNumber(min: 0.5, max: 1.0, granularity: 0.1)
        addImageView(centerRelativeMultiplierX: randomXMultiplier,
                     centerRelativeMultiplierY: randomYMultiplier,
                     scale: randomScale)
    }
    
    public func removeLastImageView() {
        guard let imageView = imageViews.last, imageViews.count > 1 else { return }
        imageView.removeConstraints(imageView.constraints)
        imageView.removeFromSuperview()
        imageViews.removeLast()
    }
    
    public func removeAllAddedImageViews() {
        for _ in 0..<imageViews.count {
            removeLastImageView()
        }
    }
    
    // MARK: - Private
    private func addImageView(centerRelativeMultiplierX: CGFloat,
                              centerRelativeMultiplierY: CGFloat,
                              scale: CGFloat = 1) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        addSubview(imageView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerX,
                               multiplier: centerRelativeMultiplierX,
                               constant: 0),
            NSLayoutConstraint(item: imageView,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerY,
                               multiplier: centerRelativeMultiplierY,
                               constant: 0)
        ])
        imageViews.append(imageView)
    }
    
    private func generateRandomNumber(min: CGFloat, max: CGFloat, granularity: CGFloat = 0.01) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(CGFloat(max) / granularity))) * granularity + CGFloat(min)
    }
}

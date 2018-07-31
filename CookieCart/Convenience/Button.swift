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

class Button: UIButton {
    struct Color {
        static let title = UIColor.white
        static let disabledTitle = #colorLiteral(red: 0.5725490196, green: 0.8, blue: 0.7764705882, alpha: 1)
        static let background = #colorLiteral(red: 0.1411764706, green: 0.5960784314, blue: 0.5529411765, alpha: 1)
        static let highlightedBackground = #colorLiteral(red: 0.1174398128, green: 0.5467238896, blue: 0.5086997258, alpha: 1)
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.highlightedBackground : Color.background
        }
    }
    
    convenience init(title: String, target: Any, selector: Selector) {
        self.init()
        
        setTitle(title, for: [])
        setTitleColor(Color.title, for: .normal)
        setTitleColor(Color.disabledTitle, for: .disabled)
        titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        backgroundColor = Color.background
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        layer.cornerRadius = 14
        layer.masksToBounds = true
        addTarget(target, action: selector, for: .touchUpInside)
    }
}

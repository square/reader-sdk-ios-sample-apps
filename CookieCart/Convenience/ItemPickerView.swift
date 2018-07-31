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

protocol ItemPickerViewDelegate: class {
    func itemPickerViewDidAddItem(_ itemPickerView: ItemPickerView)
    func itemPickerViewDidSubtractItem(_ itemPickerView: ItemPickerView)
    func itemPickerView(_ itemPickerView: ItemPickerView, didRequestCheckoutWith numberOfItems: Int, totalCost: Int)
}

class ItemPickerView: UIView {
    public weak var delegate: ItemPickerViewDelegate?
    
    // MARK: UI
    private lazy var locationNameLabel = makeLocationNameLabel()
    private lazy var hairlineView = makeHairlineView()
    private lazy var countStackView = makeCountStackView()
    private lazy var countLabel = makeCountLabel()
    private lazy var subtractButton = makeSquareButton(title: "−", target: self, selector: #selector(subtractItem))
    private lazy var addButton = makeSquareButton(title: "+", target: self, selector: #selector(addItem))
    private lazy var chargeButton = Button(title: "Charge $5.00", target: self, selector: #selector(chargeTotalAmount))
    
    // MARK: Costs
    private var totalCost: Int {
        return numberOfItems * costPerItem
    }
    private let costPerItem: Int
    private var numberOfItems = 1
    
    // MARK: More
    private var location: SQRDLocation
    private var longPressTimer: Timer?
    
    init(costPerItem: Int, location: SQRDLocation) {
        self.costPerItem = costPerItem
        self.location = location
        
        super.init(frame: .zero)
        
        // Configure view properties
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 14
        
        // Add layout margins
        let spacing: CGFloat = 16
        layoutMargins = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        // Add long press gesture recognizers to - and + buttons
        let longPressSubtract = UILongPressGestureRecognizer(target: self, action: #selector(subtractButtonLongPressed))
        let longPressAdd = UILongPressGestureRecognizer(target: self, action: #selector(addButtonLongPressed))
        subtractButton.addGestureRecognizer(longPressSubtract)
        addButton.addGestureRecognizer(longPressAdd)
        
        // Add arranged subviews [-] 1 [+]
        countStackView.addArrangedSubview(subtractButton)
        countStackView.addArrangedSubview(countLabel)
        countStackView.addArrangedSubview(addButton)
        
        // Add location name, hairline, count view, charge button
        addSubview(locationNameLabel)
        addSubview(hairlineView)
        addSubview(countStackView)
        addSubview(chargeButton)
        
        // Activate constraints
        locationNameLabel.translatesAutoresizingMaskIntoConstraints = false
        hairlineView.translatesAutoresizingMaskIntoConstraints = false
        countStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationNameLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            locationNameLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            locationNameLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            locationNameLabel.bottomAnchor.constraint(equalTo: hairlineView.topAnchor, constant: -spacing),
            
            hairlineView.leftAnchor.constraint(equalTo: leftAnchor),
            hairlineView.rightAnchor.constraint(equalTo: rightAnchor),
            hairlineView.bottomAnchor.constraint(equalTo: countStackView.topAnchor, constant: -spacing),
            
            countStackView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            countStackView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            countStackView.bottomAnchor.constraint(equalTo: chargeButton.topAnchor, constant: -spacing),
            countStackView.heightAnchor.constraint(equalToConstant: 64.0),
            
            chargeButton.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            chargeButton.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            chargeButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
        
        numberOfItemsChanged()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        numberOfItems = 0
        numberOfItemsChanged()
    }
}

// MARK: - UI
private extension ItemPickerView {
    func makeCountStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.axis = .horizontal
        return stackView
    }
    
    func makeLocationNameLabel() -> UILabel {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0.2)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = self.location.name
        return label
    }
    
    func makeCountLabel() -> UILabel {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        return label
    }
    
    func makeSquareButton(title: String, target: Any, selector: Selector) -> Button {
        let button = Button(title: title, target: target, selector: selector)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .medium)
        button.titleEdgeInsets = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        return button
    }
    
    func makeHairlineView() -> UIView {
        let hairlineHeight = 1.0 / UIScreen.main.scale
        let hairline = UIView()
        hairline.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0.4)
        hairline.heightAnchor.constraint(equalToConstant: hairlineHeight).isActive = true
        return hairline
    }
}

// MARK: - Item Count
private extension ItemPickerView {
    @objc func addItem() {
        numberOfItems += 1
        delegate?.itemPickerViewDidAddItem(self)
        numberOfItemsChanged()
    }
    
    @objc func subtractItem() {
        numberOfItems -= 1
        delegate?.itemPickerViewDidSubtractItem(self)
        numberOfItemsChanged()
    }
    
    @objc func addButtonLongPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_) in
                self.addItem()
            })
        case .ended:
            longPressTimer?.invalidate()
            longPressTimer = nil
        default:
            break
        }
    }
    
    @objc func subtractButtonLongPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_) in
                self.subtractItem()
            })
        case .ended:
            longPressTimer?.invalidate()
            longPressTimer = nil
        default:
            break
        }
    }
    
    @objc func chargeTotalAmount() {
        delegate?.itemPickerView(self, didRequestCheckoutWith: numberOfItems, totalCost: totalCost)
    }
    
    func numberOfItemsChanged() {
        let minimumCardPaymentAmount = Double(self.location.minimumCardPaymentAmountMoney.amount)
        let maximumCardPaymentAmount = Double(self.location.maximumCardPaymentAmountMoney.amount)
        let costPerItemDouble = Double(costPerItem)
        
        let minimumCount = Int(ceil(minimumCardPaymentAmount / costPerItemDouble))
        let maximumCount = Int(floor(maximumCardPaymentAmount / costPerItemDouble))
        
        numberOfItems = max(minimumCount, min(maximumCount, numberOfItems))
        countLabel.text = "\(numberOfItems)"
        chargeButton.setTitle("Charge \(format(amount: totalCost))", for: .normal)
        
        subtractButton.isEnabled = (numberOfItems > minimumCount)
        addButton.isEnabled = (numberOfItems < maximumCount)
    }
    
    func format(amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = self.location.currencyCode.isoCurrencyCode
        return formatter.string(from: NSNumber(value: Float(amount) / Float(100)))!
    }
}

//
//  PITabBar.swift
//  TabBarReplacement
//
//  Created by Anthony Picciano on 1/9/16.
//  Copyright © 2016 Anthony Picciano. All rights reserved.
//

import UIKit

@objc protocol PITabBarDelegate {
    
    @objc optional func tabBar(_ tabBar: PITabBar, didSelectItem item: UITabBarItem)
    @objc optional func tabBar(_ tabBar: PITabBar, didPrimaryAction item: UITabBarItem)
    
}

class PITabBar: UIView {
    weak var delegate: PITabBarDelegate?
    weak var selectedItem: UITabBarItem?
    
    fileprivate var _shadowImageView: UIImageView!
    fileprivate var _focusGuide: UIFocusGuide!
    fileprivate var _buttonDictionary = [UITabBarItem: PITabBarButton]()
    
    fileprivate struct Constants {
        static let shadowImageHeight = CGFloat(10.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        _shadowImageView = UIImageView()
        _shadowImageView.contentMode = .scaleToFill
        _focusGuide = UIFocusGuide()
        
        self.addSubview(_shadowImageView)
        self.addLayoutGuide(_focusGuide)
    }
    
    func setPreferredFocusedView(_ view: UIView) {
		_focusGuide.preferredFocusEnvironments = [_buttonDictionary[selectedItem!]!, view]
    }
    
    var items: [UITabBarItem]? {
        
        didSet {
            self.setNeedsDisplay()
        }
        
    }
    
    func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        self.items = items
        self.updateDisplay()
    }
    
    var barTintColor: UIColor?
    var itemSpacing: CGFloat = 40.0
    var itemOffset: CGFloat = 0.0
    var itemWidth: CGFloat = CGFloat.nan
    var translucent: Bool = true
    var backgroundImage: UIImage?
    var selectionIndicatorImage: UIImage?
    
    var titleColor = UIColor.gray {
        
        didSet {
            configureButtons()
        }
        
    }
    
    var focusedTitleColor = UIColor.white {
        
        didSet {
            configureButtons()
        }
        
    }
    
    var shadowImage: UIImage? {
        
        didSet {
            _shadowImageView.image = shadowImage
        }
        
    }
    
    func updateDisplay() {
        subviews.forEach { if ($0 is PITabBarButton) { $0.removeFromSuperview() } }
        
        if let items = items {
            for (index, item) in items.enumerated() {
                let button = PITabBarButton(type: .custom)
                button.tag = index
                configure(button, item: item)
                button.addTarget(self, action: #selector(PITabBar.buttonPressed(_:event:)), for: .primaryActionTriggered)
                button.sizeToFit()
                
                _buttonDictionary[item] = button
                self.addSubview(button)
            }
        }
    }
    
    fileprivate func configureButtons() {
        let buttons = subviews.filter { $0 is PITabBarButton }
        
        for (index, subview) in buttons.enumerated() {
            if let button = subview as? PITabBarButton {
                configure(button, item: items![index])
            }
        }
    }
    
    fileprivate func configure(_ button: PITabBarButton, item: UITabBarItem) {
        button.setImage(item.image, for: UIControlState())
        button.setImage(item.selectedImage, for: .focused)
        button.setTitle(item.title, for: UIControlState())
        
        let attributes = item.titleTextAttributes(for: UIControlState())
        let color = attributes?[NSForegroundColorAttributeName] as? UIColor ?? titleColor
        button.setTitleColor(color, for: UIControlState())
        
        let focusedAttributes = item.titleTextAttributes(for: .focused)
        let focusedColor = focusedAttributes?[NSForegroundColorAttributeName] as? UIColor ?? focusedTitleColor
        button.setTitleColor(focusedColor, for: .focused)
    }
    
    func buttonPressed(_ button: UIButton!, event: UIEvent?) {
        guard let delegate = delegate else { return }
        guard let items = items else { return }
        
        let item = items[button.tag]
        delegate.tabBar?(self, didPrimaryAction: item)
    }
    
    override func layoutSubviews() {
        var sumOfSubviewWidths:CGFloat = 0.0
        let sumOfItemSpacing:CGFloat = CGFloat(items?.count ?? 0) * itemSpacing
        
        for subview in subviews {
            if subview is PITabBarButton {
                sumOfSubviewWidths += subview.frame.size.width
            }
        }
        
        var xPos: CGFloat = ( self.frame.width - (sumOfSubviewWidths + sumOfItemSpacing) ) / 2.0 + itemOffset
        
        for subview in subviews {
            switch subview {
            case is PITabBarButton:
                var frame = CGRect.zero
                frame.size = subview.frame.size
                frame.origin.y = (140.0 - subview.frame.size.height) / 2.0
                frame.origin.x = xPos
                subview.frame = frame
                xPos += subview.frame.width + itemSpacing
            case _shadowImageView:
                _shadowImageView.frame = CGRect(x: 0.0, y: self.frame.height, width: self.frame.width, height: Constants.shadowImageHeight)
            default:
                break
            }
            
        }
        
        _focusGuide.widthAnchor.constraint(equalTo: _shadowImageView.widthAnchor).isActive = true
        _focusGuide.heightAnchor.constraint(equalTo: _shadowImageView.heightAnchor).isActive = true
        _focusGuide.centerXAnchor.constraint(equalTo: _shadowImageView.centerXAnchor).isActive = true
        _focusGuide.centerYAnchor.constraint(equalTo: _shadowImageView.centerYAnchor).isActive = true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let delegate = delegate else { return }
        guard let items = items else { return }
        guard let nextFocusedView = context.nextFocusedView else { return }
        
        switch nextFocusedView {
        case is PITabBarButton:
            let item = items[nextFocusedView.tag]
            delegate.tabBar?(self, didSelectItem: item)
        default:
            break
        }
    }
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		if let selectedItem = selectedItem {
			return [_buttonDictionary[selectedItem]!]
		}
		return super.preferredFocusEnvironments
	}

}

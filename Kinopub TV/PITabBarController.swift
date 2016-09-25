//
//  PITabBarController.swift
//  TabBarReplacement
//
//  Created by Anthony Picciano on 1/9/16.
//  Copyright © 2016 Anthony Picciano. All rights reserved.
//

import UIKit

class PITabBarController: UIViewController {
    weak var delegate: UITabBarControllerDelegate?
    
    var tabBar: PITabBar {
		get {
			return _tabBar
		}
	}
    
    fileprivate var _tabBar: PITabBar
    fileprivate var _selectedIndex: Int?
    fileprivate var _contentView: UIView!
    fileprivate var _viewControllerDictionary = [UITabBarItem: UIViewController]()
    fileprivate var _tapMenuGestureRec: UITapGestureRecognizer!
    
    fileprivate struct Constants {
        static let tabBarWidth = CGFloat(1920)
        static let tabBarHeight = CGFloat(240)
        static let initialTabBarFrame = CGRect(x: 0, y: 0, width: tabBarWidth, height: tabBarHeight)
        static let viewTransitionAnimationDuration = 0.5
        static let tabBarAnimationDuration = 0.3
    }
    
    required init?(coder aDecoder: NSCoder) {
        _tabBar = PITabBar()
        _contentView = UIView()
        
        super.init(coder: aDecoder);
        
        _tabBar.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if !tabBarHidden {
            _tabBar.frame = Constants.initialTabBarFrame
            _contentView.frame = self.view.bounds
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.insertSubview(_tabBar, at: 0)
        view.insertSubview(_contentView, at: 0)
        
        _tapMenuGestureRec = UITapGestureRecognizer(target: self, action: #selector(PITabBarController.tapMenu(_:)))
        _tapMenuGestureRec.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
        _tapMenuGestureRec.delegate = self
        view.addGestureRecognizer(_tapMenuGestureRec)
    }
    
    func tapMenu(_ recognizer: UITapGestureRecognizer) {
        if tabBarHidden {
            tabBarHidden = false
            setNeedsFocusUpdate()
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextFocusedView = context.nextFocusedView {
            tabBarHidden = !(nextFocusedView is PITabBarButton)
        }
    }
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		if tabBarHidden {
			return [(selectedViewController?.view)!]
		}
		
		if _tabBar.preferredFocusEnvironments.count > 0 {
			return _tabBar.preferredFocusEnvironments
		}
		return super.preferredFocusEnvironments
	}
	
    @IBOutlet var viewControllers: [UIViewController]! {
        
        didSet {
            var items: [UITabBarItem] = []
            
            for viewController in viewControllers {
                items.append(viewController.tabBarItem)
                
                _viewControllerDictionary[viewController.tabBarItem] = viewController
            }
            
            tabBar.setItems(items, animated: false)
        }
        
    }
    
    weak var selectedViewController: UIViewController? {
        
        get {
            if let selectedIndex = _selectedIndex , selectedIndex < viewControllers.count {
                return viewControllers[selectedIndex]
            }
            
            return nil
        }
        
        set {
            if newValue != nil && viewControllers.contains(newValue!) {
                _selectedIndex = viewControllers.index(of: newValue!)
                _tabBar.selectedItem = newValue!.tabBarItem
            } else {
                _selectedIndex = nil
                _tabBar.selectedItem = nil
            }
        }
        
    }
    
    fileprivate func selectItem(_ item: UITabBarItem) {
        // If toViewController is nil, just return.
        guard let toViewController = _viewControllerDictionary[item] else { return }
        
        let fromViewController = selectedViewController
        
        // If it's the same view controller, just return.
        if fromViewController == toViewController { return }
        
        // If it's a new child view controller, add it to child array.
        let isNewChildViewController = !childViewControllers.contains(toViewController)
        if isNewChildViewController {
            addChildViewController(toViewController)
        }
        
        // Set the toViewController.view frame onto the _contentView
        toViewController.view.frame = self._contentView.bounds
        
        // Finish the new child view controller move to parent.
        if isNewChildViewController {
            toViewController.didMove(toParentViewController: self)
        }
        
        // Configure for the new tab
        selectedViewController = toViewController
        _tabBar.setPreferredFocusedView((toViewController.view)!)
        
        /* If the fromViewController is not nil, animate the change */
        if let fromViewController = fromViewController {
            UIView.transition(from: fromViewController.view, to: toViewController.view, duration: 0.5, options: [.transitionCrossDissolve, .allowUserInteraction, .beginFromCurrentState], completion: { (finished) -> Void in
            })
        } else {    /* The fromViewController is nil, just set the toViewController without animation */
            // Finish the two view controllers change
            _contentView.addSubview((toViewController.view)!)
        }
    }
    
    fileprivate var tabBarHidden = false {
        
        willSet {
            if newValue {
                tabBarWillHide(animated: true)
            } else {
                tabBarWillShow(animated: true)
            }
        }
        
        didSet {
            if tabBarHidden {
                tabBarDidHide(animated: true)
            } else {
                tabBarDidShow(animated: true)
            }
            
            if oldValue != tabBarHidden {
                UIView.animate(withDuration: Constants.tabBarAnimationDuration, animations: { () -> Void in
                    self._tabBar.layer.transform = self.tabBarHidden ? CATransform3DMakeTranslation(0.0, Constants.tabBarHeight * -1, 0.0) : CATransform3DIdentity
                })
            }
            
            _tabBar.setPreferredFocusedView(tabBarHidden ? _tabBar : selectedViewController!.view)
        }
        
    }
    
    func tabBarWillHide(animated: Bool) {}
    func tabBarWillShow(animated: Bool) {}
    func tabBarDidHide(animated: Bool) {}
    func tabBarDidShow(animated: Bool) {}
    
}

extension PITabBarController : PITabBarDelegate {
    
    func tabBar(_ tabBar: PITabBar, didSelectItem item: UITabBarItem) {
        self.selectItem(item)
    }
    
    func tabBar(_ tabBar: PITabBar, didPrimaryAction item: UITabBarItem) {
        tabBarHidden = true
        self.setNeedsFocusUpdate()
    }
    
}

extension PITabBarController : UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === _tapMenuGestureRec {
            return tabBarHidden
        }
        
        return true
    }
    
}

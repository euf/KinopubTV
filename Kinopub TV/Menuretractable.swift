//
//  Menuretractable.swift
//  Kinopub TV
//
//  Created by Peter on 20.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

protocol MenuRetractable {
	func retractMenu(for constraint: NSLayoutConstraint, and context: UIFocusUpdateContext)
}

extension MenuRetractable where Self: UIViewController {
	func retractMenu(for constraint: NSLayoutConstraint, and context: UIFocusUpdateContext) {
		if let _ = context.previouslyFocusedView as? PITabBarButton {
			constraint.constant = 20
			view.setNeedsFocusUpdate()
		}
		if let _ = context.nextFocusedView as? PITabBarButton {
			constraint.constant = 150
		}
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
}

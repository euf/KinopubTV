//
//  BannerView.swift
//  Kinopub TV
//
//  Created by Peter on 20.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class BannerView: UIImageView {
	
	override var canBecomeFocused: Bool {
		return true
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if context.nextFocusedView == self {
			coordinator.addCoordinatedAnimations({ () -> Void in
				self.layer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
			}, completion: nil)
		} else if context.previouslyFocusedView == self {
			coordinator.addCoordinatedAnimations({ () -> Void in
				self.layer.backgroundColor = UIColor.clear.cgColor
			}, completion: nil)
		}
	}

}

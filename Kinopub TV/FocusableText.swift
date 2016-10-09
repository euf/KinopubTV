//
//  FocusableText.swift
//  Kinopub TV
//
//  Created by Peter on 14/03/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class FocusableText: UITextView {
	
	var label: String?
	var parentView: UIViewController?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.isSelectable = true
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped(gesture:)))
		tap.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
		self.addGestureRecognizer(tap)
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOffset = CGSize(width: 0, height: 2)
		self.layer.shadowOpacity = 0.4
		self.layer.shadowRadius = 8
	}
	
	func tapped(gesture: UITapGestureRecognizer) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let descriptionView = storyboard.instantiateViewController(withIdentifier: "descriptionView") as? MovieDescriptionViewController {
			if let view = parentView {
				if let label = label {
					descriptionView.descriptionText = label
					view.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
					view.present(descriptionView, animated: true, completion: nil)
				}
			}
		}
	}
	
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

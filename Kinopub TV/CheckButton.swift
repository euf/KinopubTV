//
//  CheckButton.swift
//  Kinopub TV
//
//  Created by Peter on 24/03/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class CheckButton: UIButton {

	var toggled: Bool = false {
		didSet {
//			handleStateDidChange()
		}
	}
	
/*	override func tvosButtonStyleForState(tvosButtonState: TVOSButtonState) -> TVOSButtonStyle {
		switch tvosButtonState {
		case .Focused:
			return TVOSButtonStyle(
				backgroundColor: UIColor(red: 0.388, green: 0.388, blue: 0.388, alpha: 1.00),
				backgroundImage: self.backgroundImageForState(.Focused),
				cornerRadius: 10,
				scale: 1.2,
				shadow: TVOSButtonShadow.Focused,
				textStyle: TVOSButtonLabel.DefaultText(color: UIColor.blackColor()))
		case .Highlighted:
			return TVOSButtonStyle(
				backgroundColor: UIColor(red: 0.388, green: 0.388, blue: 0.388, alpha: 1.00),
				cornerRadius: 10,
				backgroundImage: self.backgroundImageForState(.Highlighted),
				scale: 1.1,
				shadow: TVOSButtonShadow.Highlighted,
				textStyle: TVOSButtonLabel.DefaultText(color: UIColor.blackColor()))
		default:
			return TVOSButtonStyle(
				backgroundColor: UIColor(red: 0.388, green: 0.388, blue: 0.388, alpha: 1.00),
				backgroundImage: self.backgroundImageForState(.Normal),
				cornerRadius: 10,
				textStyle: TVOSButtonLabel.DefaultText(color: UIColor.whiteColor()))
		}
	}*/
	
}

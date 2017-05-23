//
//  SegueHandlerType.swift
//  Kinopub TV
//
//  Created by Peter on 20.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

protocol SegueHandlerType {
	associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
	
	func performSegue(identifier segueIdentifier: SegueIdentifier, sender: AnyObject?) {
		performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
	}
	
	func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
		guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
			fatalError("Invalid segue identifier \(String(describing: segue.identifier)).")
		}
		return segueIdentifier
	}
}

// Usage:

/*

enum SegueIdentifier: String {
	case TheRedPillExperience
	case TheBluePillExperience
}

override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

// 🎉 goodbye pyramid of doom!
switch segueIdentifierForSegue(segue) {
case .TheRedPillExperience:
print("😈")
case .TheBluePillExperience:
print("👼")
}
}

@IBAction func onRedPillButtonTap(sender: AnyObject) {
// ✅ this is how I want to write my code! Beautiful!
performSegueWithIdentifier(.TheRedPillExperience, sender: self)
}

@IBAction func onBluePillButtonTap(sender: AnyObject) {
performSegueWithIdentifier(.TheBluePillExperience, sender: self)
}




*/

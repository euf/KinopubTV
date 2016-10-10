//
//  WatchViewController.swift
//  Kinopub TV
//
//  Created by Peter on 25.09.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import Crashlytics

class WatchViewController: UIViewController {

	
	@IBOutlet var subMenuSegments: UISegmentedControl!
	@IBOutlet var subMenuTopConstraint: NSLayoutConstraint!
	
	var listController: ListViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if let _ = context.previouslyFocusedView as? PITabBarButton {
			subMenuTopConstraint.constant = 20
		}
		if let _ = context.nextFocusedView as? PITabBarButton {
			subMenuTopConstraint.constant = 150
		}
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
	
	@IBAction func subMenuChanged(_ sender: UISegmentedControl) {
		changeViewToSelectedSegment(segment: subMenuSegments.selectedSegmentIndex)
	}
	
	private func changeViewToSelectedSegment(segment: Int) {
		var type = ItemType()
		switch segment {
		case 0: type = .movies
			break
		case 1: type = .shows
			break
		case 2: type = .tvshows
			break
		case 3: type = .movies3D
			break
		case 4: type = .concerts
			break
		case 5: type = .documentaries
			break
		case 6: type = .series
			break
		default: type = .movies
		}
		listController?.viewType = type
		
//		Answers.logCustomEvent(withName: "Activation", customAttributes: ["Action":"Startup Auth Check", "Status":"Authorized"])
		Answers.logContentView(withName: "List View", contentType: type.rawValue, contentId: nil, customAttributes: nil)

	}

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "listView" {
			if let controller = segue.destination as? ListViewController {
				listController = controller
				listController?.segments = subMenuSegments
				changeViewToSelectedSegment(segment: subMenuSegments.selectedSegmentIndex)
			}
		}
    }


}

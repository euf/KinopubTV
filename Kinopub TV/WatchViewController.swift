//
//  WatchViewController.swift
//  Kinopub TV
//
//  Created by Peter on 25.09.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import Crashlytics

class WatchViewController: UIViewController, MenuRetractable {

	@IBOutlet var subMenuSegments: UISegmentedControl!
	@IBOutlet var subMenuTopConstraint: NSLayoutConstraint!
	
	var listController: ListViewController?
	
    override func viewDidLoad() {
        super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		subMenuSegments.backgroundColor = UIColor(red:0.37, green:0.37, blue:0.37, alpha:1.00)
	}
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		return [subMenuSegments]
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		retractMenu(for: subMenuTopConstraint, and: context)
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

//
//  WatchViewController.swift
//  Kinopub TV
//
//  Created by Peter on 25.09.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class WatchViewController: UIViewController {

	@IBOutlet var subMenuTopConstraint: NSLayoutConstraint!
	var constant: CGFloat? // Top animation constant
	
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

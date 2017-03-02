//
//  SortingTableViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 23/03/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class SortingTableViewCell: UITableViewCell {

	@IBOutlet var name: UILabel!
	@IBOutlet var sortIcon: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		prepareCell()
    }
	
	func prepareCell() {
		self.layer.cornerRadius = 5
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if context.nextFocusedView === self {
			self.setNeedsUpdateConstraints()
			self.backgroundColor = UIColor.darkGray
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
				self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
//				self.backgroundColor = UIColor.lightGray
//				self.tintColor = UIColor.white
			}, completion: { done in
			})
		}
		
		if context.previouslyFocusedView === self {
			self.setNeedsUpdateConstraints()
			self.backgroundColor = UIColor.clear
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
				self.transform = CGAffineTransform.identity
//				self.backgroundColor = UIColor.clear
//				self.tintColor = UIColor.white
			}, completion: { done in
			})
		}
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	

}

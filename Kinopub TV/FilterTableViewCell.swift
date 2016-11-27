//
//  FilterTableViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 22/03/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

enum CellStatus {
	case checked, unchecked
	mutating func toggle() {
		self = self == .checked ? .unchecked : .checked
	}
}

class FilterTableViewCell: UITableViewCell {
	
	var genre: Genre?
	var status: CellStatus = .unchecked {
		didSet {
			updateAccessory()
		}
	}
	
	var checkmark = UIImage(named: "icon-checkbox")
	
	@IBOutlet var filter: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
		prepareCell()
    }
	
	func prepareCell() {
		self.layer.cornerRadius = 5
	}
	
	func toggleCheckMark() {
		status.toggle()
		updateAccessory()
	}
	
	private func updateAccessory() {
		if status == .checked {
			self.accessoryView = UIImageView(image: checkmark)
		} else {
			self.accessoryView = nil
		}
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if context.nextFocusedView === self {
			self.setNeedsUpdateConstraints()
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
				self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
				self.backgroundColor = UIColor.gray
				self.tintColor = UIColor.white
			}, completion: { done in
			})
		}
		
		if context.previouslyFocusedView === self {
			self.setNeedsUpdateConstraints()
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
				self.transform = CGAffineTransform.identity
				self.backgroundColor = UIColor.clear
				self.tintColor = UIColor.white
			}, completion: { done in
			})
		}
	}
	
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }

}

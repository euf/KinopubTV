//
//  BookmarkTableViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 11.12.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class BookmarkTableViewCell: UITableViewCell {
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var updatedLabel: UILabel!
	@IBOutlet var containsLabel: UILabel!
	
	let formatter = DateFormatter()
	

    override func awakeFromNib() {
        super.awakeFromNib()
		formatter.dateFormat = "dd.mm.yyyy"
    }
	
	func prepareCell(for bookmark: Bookmark) {
		titleLabel.text = bookmark.title
		updatedLabel.text = "Обновлен: \(formatter.string(from: bookmark.updated!))"
		if let bookmarksCount = bookmark.count {
			containsLabel.text = "Содержит: \(String(bookmarksCount)) шт."
		}
		
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if context.nextFocusedView === self {
			self.backgroundColor = UIColor.darkGray
			self.setNeedsUpdateConstraints()
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
				self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
			}, completion: { done in
			})
		}
		
		if context.previouslyFocusedView === self {
			self.backgroundColor = UIColor.clear
			self.setNeedsUpdateConstraints()
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
				self.transform = CGAffineTransform.identity
			}, completion: { done in
			})
		}
	}


}

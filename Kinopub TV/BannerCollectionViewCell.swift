//
//  BannerCollectionViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 20.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AlamofireImage

class BannerCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet var poster: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var spacingConstraint: NSLayoutConstraint!
	
	var focusedSpacingConstraint: NSLayoutConstraint!

	override func awakeFromNib() {
		super.awakeFromNib()
		focusedSpacingConstraint = NSLayoutConstraint(item: poster.focusedFrameGuide, attribute: .bottomMargin, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1, constant: 0)
		focusedSpacingConstraint.isActive = false
		self.addConstraint(focusedSpacingConstraint)
		titleLabel.isHidden = true
	}
	
	internal func prepareCell(item: Item) {
		titleLabel.text = item.title
		if let p = item.posters, let image = p.big, let URL = NSURL(string: image) {
			self.poster.af_setImage(withURL: URL as URL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
		}
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		focusedSpacingConstraint.isActive = self.isFocused
		spacingConstraint.isActive = !self.isFocused
		titleLabel.isHidden = !self.isFocused
		if self == context.nextFocusedView {
			layer.zPosition = 1000
		} else {
			layer.zPosition = 100
		}
	}
	
}

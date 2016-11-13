//
//  ItemCollectionViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 28/12/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AlamofireImage

class PickCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var year: UILabel!
	@IBOutlet weak var posterSeparatorConstraint: NSLayoutConstraint!
	var data: Pick? {
		didSet {
			prepareCell()
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	private func prepareCell() {
		
		let placehoder = UIImage(named: "placeholder")
		
		title.text = data?.title
		if let p = data?.posters, let medium = p.medium {
			if let URL = NSURL(string: medium) {
				poster.af_setImage(withURL: URL as URL, placeholderImage: placehoder, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
				poster.isUserInteractionEnabled = true
			}
		}
	}
	
	func cancelPrefetching() {
		poster.af_cancelImageRequest()
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if (self == context.nextFocusedView) {
			self.title.isHidden = true
		}
		else if (self == context.previouslyFocusedView) {
			self.title.isHidden = false
		}
	}
	
    override func prepareForReuse() {
        self.poster.image = nil
    }

}

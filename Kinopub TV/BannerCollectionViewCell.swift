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
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	internal func prepareCell(item: Item) {
		if let p = item.posters, let image = p.big, let URL = NSURL(string: image) {
			self.poster.af_setImage(withURL: URL as URL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
		}
	}
	
}

//
//  TVBannerCollectionViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 25.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class TVBannerCollectionViewCell: UICollectionViewCell, APIDelegatable {
	
	var item: Item?
	
	@IBOutlet var poster: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	func prepareCell() {
//		log.debug("Preparing cell for: \(item?.title) with imdb: \(item?.imdb)")
		if let imdb = item?.imdb {
			getFanArtBy(imdb: imdb) { url in
				guard let url = url else { return }
				self.poster.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
			}
		}
	}
	
}

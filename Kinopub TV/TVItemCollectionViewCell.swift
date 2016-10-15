//
//  tvItemCollectionViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 15.10.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class TVItemCollectionViewCell: UICollectionViewCell {
	
	var streamURL: URL?
	var channel: TVChannel? {
		didSet {
			setupCell()
		}
	}
	
	@IBOutlet var poster: UIImageView!
	
	private func setupCell() {
		
		guard let logo = channel?.logo?.small, let url = URL(string: logo), let stream = channel?.stream, let streamURL = URL(string: stream) else {
			log.error("Unable to get small logo")
			return
		}
		
		poster.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
		poster.isUserInteractionEnabled = true
		self.streamURL = streamURL
	}
	
	
    
}

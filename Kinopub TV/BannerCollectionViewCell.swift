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
	
	@IBOutlet var backdrop: UIImageView!
	@IBOutlet var poster: UIImageView!
	@IBOutlet var movieTitle: UILabel!
	@IBOutlet var yearCountry: UILabel!
	@IBOutlet var introduction: UITextView!
	@IBOutlet var imdbRating: UILabel!
	@IBOutlet var kinopubRating: UILabel!
	
	func prepareCell(item: Item) {
		movieTitle.text = item.title
		introduction.text = item.plot
		
		if let p = item.posters, let image = p.big, let URL = NSURL(string: image) {
			self.poster.af_setImage(withURL: URL as URL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
			// Задний план
			backdrop.af_setImage(withURL: URL as URL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
			let blur = UIBlurEffect(style: UIBlurEffectStyle.dark)
			let blurView = UIVisualEffectView(effect: blur)
			blurView.frame = backdrop.bounds
			backdrop.addSubview(blurView)
		}
		
		if let countries = item.countries, let year = item.year {
			let countriesText = countries.takeElements(element: 3).reduce("", {$1.title! + " "})
			yearCountry.text = "\(year)г \(countriesText)"
		}
	}
	
}

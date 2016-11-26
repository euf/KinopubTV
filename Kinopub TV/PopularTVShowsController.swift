//
//  PopularTVShowsController.swift
//  Kinopub TV
//
//  Created by Peter on 25.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class PopularTVShowsController: UIViewController, KinoListable {

	var shows = [Item]() {
		didSet {
			collectionView.fadeCells()
		}
	}
	
	@IBOutlet var collectionView: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func loadPopularTVShows() { // with IMDB only!
		getPopularTVShows() { response in
			switch response {
			case .success(let items, _):
				guard let items = items else { return }
				let filteredItems = items.filter {$0.imdb != nil}
				self.shows = filteredItems
				break
			case .error(let error):
				log.error("Error getting items: \(error)")
				break
			}
		}
	}
	
}

extension PopularTVShowsController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return shows.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = shows[indexPath.row]
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tvBanner", for: indexPath) as? TVBannerCollectionViewCell {
			cell.item = item
			cell.prepareCell()
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		log.debug("Tapped on banner")
	}
	
}

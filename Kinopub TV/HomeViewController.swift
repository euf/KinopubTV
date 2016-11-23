//
//  NewViewController.swift
//  Kinopub TV
//
//  Created by Peter on 17/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, KinoListable, Menuretractable {

	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var topConstraint: NSLayoutConstraint!
	
	var bannerSource = [Item]() {
		didSet {
			fadeCells()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		collectionView.remembersLastFocusedIndexPath = true
		loadFeatured()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		var insets = self.collectionView.contentInset
		let value = (self.view.frame.size.width - (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
		insets.left = value
		insets.right = value
		collectionView.contentInset = insets
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		retractMenu(for: topConstraint, and: context)
	}
	
	
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	fileprivate func fadeCells() {
		let range = NSMakeRange(0, self.collectionView.numberOfSections)
		let sections = NSIndexSet(indexesIn: range)
		collectionView.reloadSections(sections as IndexSet)
	}
	
	fileprivate func loadFeatured() {
		getFeaturedMovies { response in
			switch response {
			case .success(let items, _):
				guard let items = items else { return }
				self.bannerSource = items
				break
			case .error(let error):
				log.error("Error getting items: \(error)")
				break
			}
		}
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return bannerSource.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = bannerSource[indexPath.row]
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath as IndexPath) as? BannerCollectionViewCell {
			cell.prepareCell(item: item)
			return cell
		}
		return UICollectionViewCell()
	}
}



//
//  PicksViewController.swift
//  Kinopub TV
//
//  Created by Peter on 17/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class PicksViewController: UIViewController {
	
	var dataStore = [Pick]()
	var page = 1
	var totalPages = 1
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var topConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
		collectionView.register(UINib(nibName: "PickCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "itemCell")
		collectionView.remembersLastFocusedIndexPath = true
		collectionView.infiniteScrollTriggerOffset = 100
		loadInfiniteScroll()
		collectionView.setContentOffset(CGPoint.init(x: 0.1, y: 100), animated: false) // Triggers infinite scroll on the very beginning
	}
	
	fileprivate func fadeCells() {
		let range = NSMakeRange(0, self.collectionView.numberOfSections)
		let sections = NSIndexSet(indexesIn: range)
		collectionView.reloadSections(sections as IndexSet)
	}
	
	internal func loadInfiniteScroll() {
		log.debug("Loafing infinite scrtoll")
		self.page = 1
		collectionView.addInfiniteScroll { [weak self] (scrollView) -> Void in
			log.debug("Scroll initied")
			guard let page = self?.page else { return }
			if self?.totalPages == page-1 {
				self?.collectionView.removeInfiniteScroll()
				return
			} else {
				self?.getItems(for: page) { pagination in
//					self?.activityIndicator.stopAnimating()
					self?.fadeCells()
					scrollView.finishInfiniteScroll()
				}
			}
		}
	}
	
	
}

extension PicksViewController: KinoPickable {

	fileprivate func getItems(for page: Int, callback: @escaping (_ pagination: Pagination?) -> ()) {
		fetchPicks(page: page) { status in
			switch status {
			case .success(let items, let pagination):
				if let items = items {
					
					guard let pagination = pagination, let totalpages = pagination.total, let current = pagination.current else {
						callback(nil)
						return
					}
					
					if totalpages > 0 {
						let firstIndex = self.dataStore.count
						var indexPaths = [IndexPath]()
						for (i, item) in items.enumerated() {
							let indexPath = IndexPath(item: firstIndex + i, section: 0)
							self.dataStore.append(item)
							indexPaths.append(indexPath)
						}
						self.collectionView.performBatchUpdates({ () -> Void in
							self.collectionView.insertItems(at: indexPaths)
						}, completion: { (finished) -> Void in
							
						})
						self.totalPages = totalpages
						self.page = current+1
					}
					
					callback(pagination)
				}
				break
			case .error(let error):
				log.error("Error getting items: \(error)")
				callback(nil)
				break
			}
		}
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		let nextFocus = context.nextFocusedView!
		let prevFocus = context.previouslyFocusedView!
		if nextFocus.isMember(of: PITabBarButton.self) && prevFocus.isMember(of: PickCollectionViewCell.self) {
			topConstraint.constant = 100
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
				self.setNeedsFocusUpdate()
				self.view.layoutIfNeeded()
			}, completion: nil)
		} else if nextFocus.isMember(of: PickCollectionViewCell.self) && prevFocus.isMember(of: PITabBarButton.self) {
			topConstraint.constant = 20
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
				self.setNeedsFocusUpdate()
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
}

extension PicksViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataStore.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath as IndexPath) as? PickCollectionViewCell {
			let item = dataStore[indexPath.row]
			cell.data = item
			return cell
		}
		return UICollectionViewCell()
	}
	
}

//
//  ListViewController.swift
//  Kinopub TV
//
//  Created by Peter on 15/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyUserDefaults

fileprivate let reuseIdentifier = "itemCell"
fileprivate let sectionInsets = UIEdgeInsets(top: 40.0, left: 50.0, bottom: 40.0, right: 50.0)
fileprivate let PreloadMargin = 100

class ListViewController: UIViewController, UIGestureRecognizerDelegate {

	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	var shouldFocusSubmenu = false
	var segments: UISegmentedControl?
	
	var dataStore = [Item]()
	var page = 1
	var totalPages = 1
	
	var year: String? = nil {
		didSet { if collectionView != nil { loadInfiniteScroll() } }
	}
	
	var genre: String? {
		didSet { if collectionView != nil { loadInfiniteScroll() } }
	}
	
	var sort: String? = nil {
		didSet { if collectionView != nil { loadInfiniteScroll() } }
	}
	
	var viewType: ItemType? {
		didSet { if collectionView != nil { loadInfiniteScroll() } }
	}
	
	var pick: Pick? {
		didSet { if collectionView != nil { loadPicks() } }
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		collectionView.remembersLastFocusedIndexPath = true
		
		if let _ = viewType {
			let menuGesture = UITapGestureRecognizer(target: self, action: #selector(self.focusSubMenu(_:)))
			menuGesture.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
			menuGesture.delegate = self
			collectionView.addGestureRecognizer(menuGesture)
			collectionView.infiniteScrollTriggerOffset = 500
			loadInfiniteScroll()
		} else {
			loadPicks()
		}
		collectionView.setContentOffset(CGPoint.init(x: 0.1, y: 300), animated: false) // Triggers infinite scroll on the very beginning
	}
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		if shouldFocusSubmenu && segments != nil { return [segments!] }
		return super.preferredFocusEnvironments
	}
	
	internal func focusSubMenu(_ recognizer: UITapGestureRecognizer) {
		shouldFocusSubmenu = true
		setNeedsFocusUpdate()
		updateFocusIfNeeded()
		shouldFocusSubmenu = false
	}
}

extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegate, /*UICollectionViewDataSourcePrefetching,*/ KinoListable {
	
	fileprivate func fadeCells() {
		let range = NSMakeRange(0, self.collectionView.numberOfSections)
		let sections = NSIndexSet(indexesIn: range)
		collectionView.reloadSections(sections as IndexSet)
	}
	
	internal func loadPicks() {
		getPickItems() { pagination in
			self.activityIndicator.stopAnimating()
		}
	}
	
	internal func loadInfiniteScroll() {
		self.page = 1
		if dataStore.count > 0 {
			activityIndicator.startAnimating()
			self.dataStore.removeAll(keepingCapacity: false)
			self.fadeCells()
		}
		self.collectionView.addInfiniteScroll { [weak self] (scrollView) -> Void in
			guard let page = self?.page else { return }
			
			if self?.totalPages == page-1 {
				self?.collectionView.removeInfiniteScroll()
				return
			} else {
				// TODO : Add genre, sort, year?
				self?.getItems(for: page) { pagination in
					self?.activityIndicator.stopAnimating()
					scrollView.finishInfiniteScroll()
				}
			}
		}
		
	}
	
	fileprivate func getPickItems(callback: @escaping (_ pagination: Pagination?) -> ()) {
		guard let pick = pick else {return}
		fetchItems(for: pick) { status in
			self.processItems(for: status) { pagination in
				callback(pagination)
			}
		}
	}

	fileprivate func getItems(for page: Int, callback: @escaping (_ pagination: Pagination?) -> ()) {
		if let type = viewType {
			fetchItems(for: type, page: page) { status in
				self.processItems(for: status) { pagination in
					callback(pagination)
				}
			}
		}
	}
	
	fileprivate func processItems(for status: ItemsResponse, callback: @escaping (_ pagination: Pagination?) -> ()) {
		switch status {
		case .success(let items, let pagination):
			if let items = items {
				
				if let _ = pick {
					
					self.dataStore = items
					self.collectionView.reloadData()
					
				} else {
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
	
	private func visibleIndexPathsForIndexes(_ indexes: CountableRange<Int>) -> [IndexPath]? {
		return collectionView.indexPathsForVisibleItems.filter {indexes.contains(($0 as NSIndexPath).row) }
	}

	private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataStore.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as? ItemCollectionViewCell {
			let item = dataStore[indexPath.row]
			cell.data = item
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = dataStore[indexPath.row]
		let controller = ItemViewController(nibName: "ItemViewController", bundle: nil)
		let subtype = item.subtype != "" ? ItemSubType(rawValue: item.subtype!) : nil
		controller.kinoItem = KinoItem(id: item.id, type: ItemType(rawValue: item.type!), subtype: subtype)
		self.present(controller, animated: true, completion: nil)
	}
	
	// MARK: Prefetching
	
/*	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as? ItemCollectionViewCell {
				let item = dataStore[indexPath.row]
				cell.data = item
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as? ItemCollectionViewCell {
				cell.cancelPrefetching()
			}
		}
	}*/

}

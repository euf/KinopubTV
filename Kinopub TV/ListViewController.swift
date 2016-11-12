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

	var pagesLoading = Set<Int>()
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	var dataStore = [Item]()
	var page = 1
	var totalPages = 1
	
	var viewType: ItemType? {
		didSet {
			if collectionView != nil {
				loadInfiniteScroll(genre: nil, year: nil, sort: nil)
			}
		}
	}
	
	var shouldFocusSubmenu = false
	var segments: UISegmentedControl?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let menuGesture = UITapGestureRecognizer(target: self, action: #selector(self.focusSubMenu(_:)))
		menuGesture.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
		menuGesture.delegate = self
		collectionView.addGestureRecognizer(menuGesture)
		collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		collectionView.remembersLastFocusedIndexPath = true
		collectionView.prefetchDataSource = self
		collectionView.infiniteScrollTriggerOffset = 500
		loadInfiniteScroll(genre: nil, year: nil, sort: nil)
	}
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		if shouldFocusSubmenu { return [segments!] }
		return super.preferredFocusEnvironments
	}
	
	internal func focusSubMenu(_ recognizer: UITapGestureRecognizer) {
		shouldFocusSubmenu = true
		setNeedsFocusUpdate()
		updateFocusIfNeeded()
		shouldFocusSubmenu = false
	}
}

extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, KinoListable {
	
	fileprivate func fadeCells() {
		let range = NSMakeRange(0, self.collectionView.numberOfSections)
		let sections = NSIndexSet(indexesIn: range)
		collectionView.reloadSections(sections as IndexSet)
	}
	
	internal func loadInfiniteScroll(genre: Genre?, year: String?, sort: String?) {
		self.page = 1
		if dataStore.count > 0 {
			self.dataStore.removeAll(keepingCapacity: false)
			self.fadeCells()
		}
		self.collectionView.addInfiniteScroll { [weak self] (scrollView) -> Void in
			
			guard let page = self?.page else { return }
			if self?.totalPages == page-1 {
				self?.collectionView.removeInfiniteScroll()
				return
			} else {
				self?.getItems(page: page) { items, pagination in
					
					guard let pagination = pagination, let totalpages = pagination.total, let current = pagination.current else {return}
					guard let items = items else { return }
					// log.debug("Paging result: total pages -> \(totalpages)")
					if totalpages == 0 {
						log.debug("We got 0 results. Resetting")
						scrollView.finishInfiniteScroll()
					} else {
						
						let firstIndex = self?.dataStore.count
						var indexPaths = [IndexPath]()
						for (i, item) in items.enumerated() {
							let indexPath = IndexPath(item: firstIndex! + i, section: 0)
							self?.dataStore.append(item)
							indexPaths.append(indexPath)
						}
						// log.debug("Performing batch update of collectionView")
						self?.collectionView.performBatchUpdates({ () -> Void in
							self?.collectionView.insertItems(at: indexPaths)
						}, completion: { (finished) -> Void in
							// Do something at the very end. Or not :)
						})
						self?.totalPages = totalpages
						self?.page = current+1 // Next page
						scrollView.finishInfiniteScroll()
					}
				}
			}
		}
	}

	fileprivate func getItems(page: Int, callback: @escaping (_ items: [Item]?, _ pagination: Pagination?) -> ()) {
		if let type = viewType {
			fetchItems(type: type, page: page) { (status) in
				switch status {
				case .success(let items, let pagination):
					if let items = items {
						callback(items, pagination)
					}
					break
				case .error(let error):
					log.error("Error getting items: \(error)")
					callback(nil, nil)
					break
				}
			}
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
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
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
	}

}

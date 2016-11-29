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

	@IBOutlet var filterView: UIView!
	@IBOutlet var filterLabel: UILabel!
	@IBOutlet var filterViewHeight: NSLayoutConstraint!
	@IBOutlet var filterBottomConstraint: NSLayoutConstraint!
	
	@IBOutlet var picksBarView: UIView!
	@IBOutlet var picksCategoryLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var collectionTopConstraint: NSLayoutConstraint!
	
	let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
	var shouldFocusSubmenu = false
	var segments: UISegmentedControl?
	var parentView: WatchViewController?
	var currentFilter = Filter.defaultFilter()
	
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
	
	var pick: Pick?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let parent = parentView {
			parent.definesPresentationContext = true
		}
		// Gesture recognizer for filters
		let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ListViewController.openFilters))
		lpgr.minimumPressDuration = 0.5
		lpgr.delaysTouchesBegan = true
		self.view.addGestureRecognizer(lpgr)
		filterView.addBlurEffect()
		collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		collectionView.remembersLastFocusedIndexPath = false
		if let _ = viewType {
			let menuGesture = UITapGestureRecognizer(target: self, action: #selector(self.focusSubMenu(_:)))
			menuGesture.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
			menuGesture.delegate = self
			collectionView.addGestureRecognizer(menuGesture)
			collectionView.infiniteScrollTriggerOffset = 500
			collectionView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
			collectionView.remembersLastFocusedIndexPath = true
			collectionTopConstraint.constant = 10
			loadInfiniteScroll()
		} else {
			picksBarView.isHidden = false
			collectionTopConstraint.constant = 60
			picksCategoryLabel.text = pick?.title
			picksBarView.addBlurEffect()
			loadPicks()
		}
		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
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
	
/*	internal func setupGestureRecognizers() {
		// Filters
		let directions: [UISwipeGestureRecognizerDirection] = [.up, .down]
		for direction in directions {
			let gesture = UISwipeGestureRecognizer(target: self, action: #selector(ListViewController.swiped(_:)))
			gesture.direction = direction
			self.view.addGestureRecognizer(gesture)
		}
	}*/

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

extension ListViewController: FiltersViewControllerDelegate {
	
	func openFilters() {
		
		let filtersController = storyboard?.instantiateViewController(withIdentifier: "filtersController") as! FiltersViewController
		filtersController.modalPresentationStyle = .overFullScreen
		filtersController.currentView = viewType!
		filtersController.delegate = self
		visualEffectView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height+100)
		parentView?.view.addSubview(visualEffectView)
		collectionView.setContentOffset(CGPoint.zero, animated: true)
		present(filtersController, animated: true) {
			self.segments?.isHidden = true
			filtersController.configure(with: self.currentFilter)
		}
	}
	
	func filtersDidSelectFilter(filter: Filter) {
		currentFilter = filter
		filterLabel.text = "Жанр: \(filter.genre?.title ?? "Все"), Год: \(filter.yearString()), Сортировка: \(filter.sortBy?.name() ?? "По дате добавления")"
//		loadInfiniteScroll(filter.genre, year: filter.yearString(), sort: filter.sortBy?.desc())
	}
	
	func filtersDidDisappear() {
		self.segments?.isHidden = false
		UIView.animate(withDuration: 0.4, animations: {
			self.visualEffectView.alpha = 0.0
		}) { completed in
			self.visualEffectView.removeFromSuperview();
			self.visualEffectView.alpha = 1.0
		}
	}
}

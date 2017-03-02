//
//  BookmarksViewController.swift
//  Kinopub TV
//
//  Created by Peter on 11.12.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class BookmarksViewController: UIViewController, MenuRetractable {
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var topConstraint: NSLayoutConstraint!
	
	var page = 1
	var totalPages = 1
	var currentBookmark = 0
	
	var bookmarks = [Bookmark]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	var items = [Item]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "itemCell")
		collectionView.remembersLastFocusedIndexPath = true
//		collectionView.infiniteScrollTriggerOffset = 20
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		getBookmarks()
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		retractMenu(for: topConstraint, and: context)
	}
	
/*	func loadInfiniteScroll() {
		collectionView.setContentOffset(CGPoint.init(x: 0.1, y: 0.1), animated: false) // Triggers infinite scroll on the very beginning
		page = 1 // Starting from first page
		collectionView.addInfiniteScroll { [weak self] (scrollView) -> Void in
			log.debug("Calling infinite scroll from Bookmarks")
			guard let page = self?.page else { return }
			if self?.totalPages == page-1 {
				self?.collectionView.removeInfiniteScroll()
				return
			} else {
				log.debug("Getting new items")
				self?.getItems(for: page) { pagination in
					self?.collectionView.fadeCells()
					scrollView.finishInfiniteScroll()
				}
			}
		}
	}*/

}

extension BookmarksViewController: Bookmarkable {
	
	func getItems(for page: Int, callback: @escaping (_ pagination: Pagination?) -> ()) {
		log.debug("Fetching new items")
		fetchItems(for: currentBookmark, page: page) { status in
			self.processItems(for: status) { pagination in
				callback(pagination)
			}
		}
	}
	
	fileprivate func getBookmarks() {
		fetchBookmarks() { response in
			switch response {
			case .success(let channels):
				if let channels = channels {
					self.bookmarks = channels
				}
				break
			case .error(let error):
				log.error("Error getting channels: \(error)")
				break
			}
		}
	}
	
	fileprivate func processItems(for status: ItemsResponse, callback: @escaping (_ pagination: Pagination?) -> ()) {
		switch status {
		case .success(let items, _):
			if let items = items {
				
				
				self.items = items
				self.collectionView.fadeCells()
				/*
				guard let pagination = pagination, let totalpages = pagination.total, let current = pagination.current else {
					callback(nil)
					return
				}
				
				
				if totalpages > 0 {
					let firstIndex = self.items.count
					var indexPaths = [IndexPath]()
					for (i, item) in items.enumerated() {
						let indexPath = IndexPath(item: firstIndex + i, section: 0)
						self.items.append(item)
						indexPaths.append(indexPath)
					}
					
					collectionView.reloadData()
					self.collectionView.performBatchUpdates({ () -> Void in
						self.collectionView.insertItems(at: indexPaths)
					}, completion: { (finished) -> Void in
					
					})
					self.totalPages = totalpages
					self.page = current+1
				}
				callback(pagination)
				*/
				callback(nil)
			}
			break
		case .error(let error):
			log.error("Error getting items: \(error)")
			callback(nil)
			break
		}
	}
}

extension BookmarksViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return bookmarks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let bookmark = bookmarks[indexPath.row]
		if let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as? BookmarkTableViewCell {
			cell.tag = bookmark.id!
			cell.prepareCell(for: bookmark)
			return cell
		} else {
			return UITableViewCell()
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) {
			currentBookmark = cell.tag
			getItems(for: 1) { pagination in
				log.debug("Pagination response from collection")
			}
//			self.collectionView.removeInfiniteScroll()
//			loadInfiniteScroll()
		}
	}
}

extension BookmarksViewController: UICollectionViewDelegate, UICollectionViewDataSource {

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = items[indexPath.row]
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCollectionViewCell {
			cell.data = item
			return cell
		} else {
			return UICollectionViewCell()
		}
	}
	
}


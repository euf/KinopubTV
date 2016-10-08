////
////  ListViewController.swift
////  Kinopub TV
////
////  Created by Peter on 15/09/16.
////  Copyright © 2016 Peter Tikhomirov. All rights reserved.
////
//
//import UIKit
//import AlamofireImage
//import SwiftyUserDefaults
//import PagedArray
//
//private let reuseIdentifier = "itemCell"
//private let sectionInsets = UIEdgeInsets(top: 40.0, left: 50.0, bottom: 40.0, right: 50.0)
//let PreloadMargin = 20
//
//class ListViewController: UIViewController, UIGestureRecognizerDelegate {
//	
//	@IBOutlet var collectionView: UICollectionView!
//	
//	//	var totalPages = 1
//	//	var currentPage = 1
//	var viewType: ItemType? {
//		didSet {
//			print("Changed view type")
//		}
//	}
//	
//	/*	var dataStore = [Item]() {
//	didSet {
//	performDataChanges()
//	}
//	}*/
//	
//	private var dataStore = PagedArray<Item>(count: 1, pageSize: 1) {
//		didSet {
//			if self.dataStore.count > oldValue.count
//			{
//				self.collectionView.reloadData()
//			}
//		}
//	}
//	
//	var shouldFocusSubmenu = false
//	var segments: UISegmentedControl?
//	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		let menuGesture = UITapGestureRecognizer(target: self, action: #selector(self.focusSubMenu(_:)))
//		menuGesture.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
//		menuGesture.delegate = self
//		collectionView.addGestureRecognizer(menuGesture)
//		collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
//		collectionView.remembersLastFocusedIndexPath = false
//		//		loadInfiniteScroll(genre: nil, year: nil, sort: nil)
//		
//		
//		getItems(page: 1) { items, pagination in
//			guard let items = items, let pagination = pagination else {return}
//			log.debug("Setting total count to: \(pagination.totalItems)")
//			self.dataStore = PagedArray<Item>(count: pagination.totalItems!, pageSize: 50)
//			self.dataStore.set(items, forPage: 1)
//			self.collectionView.reloadData()
//		}
//		
//	}
//	
//	override var preferredFocusEnvironments: [UIFocusEnvironment] {
//		if shouldFocusSubmenu { return [segments!] }
//		return super.preferredFocusEnvironments
//	}
//	
//	func focusSubMenu(_ recognizer: UITapGestureRecognizer) {
//		shouldFocusSubmenu = true
//		setNeedsFocusUpdate()
//		updateFocusIfNeeded()
//		shouldFocusSubmenu = false
//	}
//	
//	func performDataChanges() {
//		let range = NSMakeRange(0, self.collectionView.numberOfSections)
//		let sections = NSIndexSet(indexesIn: range)
//		collectionView.reloadSections(sections as IndexSet)
//		let index = IndexPath(item: 0, section: 0)
//		collectionView.scrollToItem(at: index, at: .top, animated: false)
//	}
//	
//	override func didReceiveMemoryWarning() {
//		super.didReceiveMemoryWarning()
//	}
//	
//}
//
//extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegate, KinoListable {
//	
//	func getItems(page: Int, callback: @escaping (_ items: [Item]?, _ pagination: Pagination?) -> ()) {
//		if let type = viewType {
//			fetchItems(type: type, page: page) { (status) in
//				switch status {
//				case .success(let items, let pagination):
//					if let items = items {
//						
//						callback(items, pagination)
//						
//					}
//					break
//				case .error(let error):
//					log.error("Error getting items: \(error)")
//					callback(nil, nil)
//					// Maybe show it on the screen
//					break
//				}
//			}
//		}
//	}
//	
//	fileprivate func loadDataIfNeededForRow(_ row: Int) {
//		log.debug("Attempting to get more data")
//		
//		let currentPage = dataStore.page(for: row)
//		log.debug("Current page: \(currentPage)")
//		
//		if needsLoadDataForPage(currentPage) {
//			loadDataForPage(currentPage)
//		}
//		
//		let preloadIndex = row+PreloadMargin
//		if preloadIndex < dataStore.endIndex {
//			let preloadPage = dataStore.page(for: preloadIndex)
//			if preloadPage > currentPage && needsLoadDataForPage(preloadPage) {
//				loadDataForPage(preloadPage)
//			}
//		}
//	}
//	
//	private func needsLoadDataForPage(_ page: Int) -> Bool {
//		return false
//	}
//	
//	private func visibleIndexPathsForIndexes(_ indexes: CountableRange<Int>) -> [IndexPath]? {
//		return collectionView.indexPathsForVisibleItems.filter {indexes.contains(($0 as NSIndexPath).row) }
//	}
//	
//	private func loadDataForPage(_ page: Int) {
//		log.debug("Loading data for page: \(page)")
//		let indexes = dataStore.indexes(for: page)
//		
//		getItems(page: page) { (items, pagination) in
//			
//			guard let items = items, let pagination = pagination, let indexes = indexes else {return}
//			
//			self.dataStore.set(items, forPage: pagination.current!)
//			if let indexPathsToReload = self.visibleIndexPathsForIndexes(indexes) {
//				self.collectionView.reloadItems(at: indexPathsToReload)
//			}
//		}
//	}
//	
//	private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//		return 1
//	}
//	
//	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		guard let dataStore = dataStore else { return 0 }
//		return dataStore.count
//	}
//	
//	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		
//		loadDataIfNeededForRow((indexPath as NSIndexPath).row)
//		log.debug("Calling cell")
//		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as? ItemCollectionViewCell {
//			let item = dataStore?[indexPath.row]
//			cell.data = item
//			return cell
//		}
//		return UICollectionViewCell()
//	}
//	
//	//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//	//		return sectionInsets
//	//	}
//	//
//	//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//	//		return 30.0
//	//	}
//	//
//	//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//	//		return 30.0
//	//	}
//	//
//	//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//	//		return CGSize(width: 305, height: 475)
//	//	}
//	
//	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//		//		let item = dataStore[indexPath.row]
//		//		if let controller = storyboard?.instantiateViewControllerWithIdentifier("item") as? ItemViewController {
//		//			let subtype = item.subtype != "" ? ItemSubType(rawValue: item.subtype!) : nil
//		//			controller.kinoItem = KinoItem(id: item.id, type: ItemType(rawValue: item.type!), subtype: subtype)
//		//			navigationController?.pushViewController(controller, animated: true)
//		//			//self.presentViewController(controller, animated: true, completion: nil)
//		//		}
//	}
//	
//}

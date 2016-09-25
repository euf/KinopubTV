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

private let reuseIdentifier = "itemCell"
private let sectionInsets = UIEdgeInsets(top: 40.0, left: 50.0, bottom: 40.0, right: 50.0)

class ListViewController: UIViewController, UIGestureRecognizerDelegate {
	
	var currentPage = 1
	var viewType: ItemType? {
		didSet {
			getItems(page: 1) {}
		}
	}
	var dataStore = [Item]() {
		didSet {
			let range = NSMakeRange(0, self.collectionView.numberOfSections)
			let sections = NSIndexSet(indexesIn: range)
			self.collectionView.reloadSections(sections as IndexSet)
			//self.collectionView.reloadData()
		}
	}
	var shouldFocusSubmenu = false
	var segments: UISegmentedControl?
	
	@IBOutlet var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let menuGesture = UITapGestureRecognizer(target: self, action: #selector(self.focusSubMenu(_:)))
		menuGesture.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
		menuGesture.delegate = self
		collectionView.addGestureRecognizer(menuGesture)
		self.collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		
    }
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		
		if shouldFocusSubmenu {
			return [segments!]
		}
		
		return super.preferredFocusEnvironments
	}
	
	func focusSubMenu(_ recognizer: UITapGestureRecognizer) {
		shouldFocusSubmenu = true
		setNeedsFocusUpdate()
		updateFocusIfNeeded()
		shouldFocusSubmenu = false
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegate, KinoListable {
	
	func getItems(page: Int, callback: @escaping () -> ()) {
		if let type = viewType {
			fetchItems(type: type, page: page) { (status) in
				switch status {
				case .success(let items):
					if let items = items {
						if page > 1 {
							self.dataStore.append(contentsOf: items)
						} else {
							self.dataStore = items
						}
						callback()
					}
					break
				case .error(let error):
					log.error("Error getting items: \(error)")
					callback()
					// Maybe show it on the screen
					break
				}
			}
		}
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
	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//		return sectionInsets
//	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//		return 30.0
//	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//		return 30.0
//	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//		return CGSize(width: 305, height: 475)
//	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//		let item = dataStore[indexPath.row]
//		if let controller = storyboard?.instantiateViewControllerWithIdentifier("item") as? ItemViewController {
//			let subtype = item.subtype != "" ? ItemSubType(rawValue: item.subtype!) : nil
//			controller.kinoItem = KinoItem(id: item.id, type: ItemType(rawValue: item.type!), subtype: subtype)
//			navigationController?.pushViewController(controller, animated: true)
//			//self.presentViewController(controller, animated: true, completion: nil)
//		}
	}
	
}

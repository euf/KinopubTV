//
//  SearchResultsViewController.swift
//  Kinopub TV
//
//  Created by Peter on 28/02/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

protocol SearchResultsViewControllerDelegate: class {
	func itemSelected(item: AnyObject)
}
private let reuseIdentifier = "itemCell"
private let sectionInsets = UIEdgeInsets(top: 40.0, left: 50.0, bottom: 40.0, right: 50.0)

class SearchResultsViewController: UIViewController {
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var resultCountLabel: UILabel!
	@IBOutlet weak var notFoundView: UIView!
	
	weak var delegate: SearchResultsViewControllerDelegate?
	
	fileprivate var items = [Item]()
	
	var searchString = "" {
		didSet {
			guard searchString != oldValue else { return }
			
			if searchString.characters.count  < 3 {
				self.items = []
				updateDisplay(true)
			}
			else {
				searchKinopub(for: searchString)
			}
			
			collectionView!.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(red:0.09, green:0.094, blue:0.105, alpha:1)
		collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		updateDisplay(true)
	}
	
}

extension SearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate, KinoSearchable {
	
	func searchKinopub(for searchText: String) {
		self.items = []
		search(for: searchText) { response in
			switch response {
			case .success(let items, _):
				guard let items = items else { return }
				self.items = items
				self.updateDisplay()
				break
			case .error(let error):
				log.error("Error getting items: \(error)")
				break
			}
		}
	}
	
	func updateDisplay(_ notFoundMessageSuppressed: Bool = false) {
		if items.count == 0 {
			notFoundView.isHidden = notFoundMessageSuppressed
			resultCountLabel.text = ""
		} else {
			notFoundView.isHidden = true
			resultCountLabel.text = "\(items.count) \(items.count == 1 ? "результат" : "резальтатов")"
		}
		collectionView.reloadData()
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
		let item = items[indexPath.row]
		cell.data = item
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let cell = collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell {
			let item = ItemViewController(nibName: "ItemViewController", bundle: nil)
			item.item = cell.data
			self.present(item, animated: true, completion: nil)
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return sectionInsets
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 50.0
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 30.0
	}
	
	
	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//		return CGSize(width: 305, height: 475	)
//	}
	
}


extension SearchResultsViewController : UISearchResultsUpdating {
	
	public func updateSearchResults(for searchController: UISearchController) {
		searchString = searchController.searchBar.text ?? ""
	}
}

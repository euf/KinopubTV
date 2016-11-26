//
//  SearchViewController.swift
//  Kinopub TV
//
//  Created by Peter on 28/02/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class SearchViewController: UINavigationController {
	
	static let searchBarVerticalOffset = CGFloat(50)
    var searchController : UISearchController?
	var adjustedSearchBarFrame = CGRect.zero
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.view.backgroundColor = UIColor(red:0.09, green:0.094, blue:0.105, alpha:1)
		self.tabBarItem.title = "Поиск"
//		self.tabBarItem.image = TabBarReplacementStyleKit.imageOfSearch(focused: false)
//		self.tabBarItem.selectedImage = TabBarReplacementStyleKit.imageOfSearch(focused: true)
        self.addContent()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let container = self.viewControllers.first as? UISearchContainerViewController {
            if (container.presentedViewController == nil) {
                let newContainer = UISearchContainerViewController(searchController: searchController!)
                setViewControllers([newContainer], animated: false)
            }
        }
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// NOTE: Move the search controller down so that it is below the tab bar
		if let container = self.viewControllers.first as? UISearchContainerViewController {
			if  adjustedSearchBarFrame == CGRect.zero {
				adjustedSearchBarFrame = container.searchController.view.frame
				adjustedSearchBarFrame.origin.y = SearchViewController.searchBarVerticalOffset
				adjustedSearchBarFrame.size.height = adjustedSearchBarFrame.size.height - SearchViewController.searchBarVerticalOffset
			}
			container.searchController.view.frame = adjustedSearchBarFrame
		}
	}
	
	func addContent() {
        if searchController == nil {
			let resultsController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchResults") as! SearchResultsViewController
            resultsController.delegate = self
			log.debug("Initialized search controller")
            searchController = UISearchController(searchResultsController: resultsController)
            searchController!.searchResultsUpdater = resultsController
            searchController!.searchBar.keyboardAppearance = .dark
            searchController!.searchBar.placeholder = "Поиск"
            searchController!.searchBar.searchTextPositionAdjustment = UIOffsetMake(10, 0);
            searchController!.obscuresBackgroundDuringPresentation = false
        }
        let newContainer = UISearchContainerViewController(searchController: searchController!)
        setViewControllers([newContainer], animated: false)
	}
	
}

extension SearchViewController: SearchResultsViewControllerDelegate {
	
	func itemSelected(item: AnyObject) {
		print("selected item in search results")
		print(item)
		// TODO: Implement this
	}
	
}

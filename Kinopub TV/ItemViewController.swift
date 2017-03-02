//
//  ItemViewController.swift
//  Kinopub TV
//
//  Created by Peter on 09.10.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AVKit
import Cosmos

class ItemViewController: UIViewController {
	
	let identifier = "EpisodeCell"
	var playerController: AVPlayerViewController!
	
	var item: Item?
	var kinoItem: KinoItem?
	var selectedMedia: File?
	var isMovie = true
	var movieVideo: Video?
	var availableMedia = [File]() {
		didSet {
			setQuality()
		}
	}
	var episodes = [Video]() {
		didSet {
			//print("Reloading data")
			//collectionView.reloadData()
		}
	}
	var seasons: [Season]? {
		didSet {
//			self.tableView.reloadData()
//			self.tableView.layoutIfNeeded()
			//let range = NSMakeRange(0, self.tableView.numberOfSections)
			//let sections = NSIndexSet(indexesInRange: range)
			//self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Automatic)
		}
	}
	var seasonsSegment: UISegmentedControl!
	var currentSeason: Season? = nil
	var lastSelectedIndex: IndexPath?
	var nextEpisode: Video?
	
	@IBOutlet var progressBar: UIProgressView!
	@IBOutlet var watchMovieButtonConstraint: NSLayoutConstraint!
	@IBOutlet var watchMovieButtonBottomConstraint: NSLayoutConstraint!

	@IBOutlet weak var bg: UIImageView!
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet var movieWatchedRibbon: UIImageView!
	@IBOutlet weak var titleRu: UILabel!
	@IBOutlet weak var titleEn: UILabel!
	@IBOutlet var intro: FocusableText!

	@IBOutlet weak var director: UILabel!
	@IBOutlet weak var cast: UILabel!
	@IBOutlet weak var country: UILabel!
	@IBOutlet weak var year: UILabel!
	@IBOutlet weak var durationGenre: UILabel!
	@IBOutlet var traslationText: UILabel!

	@IBOutlet weak var rating: UILabel!
	@IBOutlet weak var stars: CosmosView!
	@IBOutlet weak var directorLabel: UILabel!
	@IBOutlet weak var castLabel: UILabel!
	@IBOutlet var seasonLabel: UILabel!

	@IBOutlet weak var qualitySegment: UISegmentedControl!
	@IBOutlet var seasonsScroll: UIScrollView!

	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var trailerButton: UIButton!
	@IBOutlet weak var watchedButton: UIButton!
	@IBOutlet weak var likedButton: UIButton!

	@IBOutlet weak var watchMovieLabel: UILabel!
	@IBOutlet weak var watchTrailerLabel: UILabel!
	@IBOutlet weak var markWatchedLabel: UILabel!
	@IBOutlet weak var addFavoriteLabel: UILabel!
	@IBOutlet var collectionView: UICollectionView!

	@IBOutlet var loadingCover: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		prepareForDisplay()
		collectionView.register(UINib(nibName: "EpisodeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
	
	@IBAction func watchMovie(_ sender: AnyObject) { playMovie() }
	
	@IBAction func watchTrailer(_ sender: AnyObject) { playTrailer() }
	
	@IBAction func setMovieWatched(_ sender: AnyObject) { markWatched() }
	
	@IBAction func bookMarkMovie(_ sender: AnyObject) { addToFavorites() }
	
	@IBAction func qualitySegmentChanged(_ sender: UISegmentedControl) { updateQuality(control: sender) }

}


////
////  ItemViewController.swift
////  Kinopub TV
////
////  Created by Peter on 06/01/16.
////  Copyright © 2016 Peter Tikhomirov. All rights reserved.
////
//
//import UIKit
//import SwiftyUserDefaults
//import AlamofireImage
//import Cosmos
//import AVKit
//import AVFoundation
//import XCDYouTubeKit
//
//class ItemViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//	
//	var item: Item?
//	var movie: Movie?
//	var series: Series?
//	var kinoController: KinoController?
//	var itemType: ItemType?
//	var isMovie = true
//	var availableMedia = [File]() {
//		didSet {
//			setQuality()
//		}
//	}
//	var selectedMedia: File?
//	var movieVideo: Video?
//	var kinoPoisk: Kinopoisk?
//	var seasons = [Season]()
//	var currentSeason = Season!(nil)
//	var episodes = [Video]() {
//		didSet {
//			//print("Reloading data")
//			//collectionView.reloadData()
//		}
//	}
//	
//	var lastSelectedIndex: NSIndexPath?
//	
//	var seasonsSegment: UISegmentedControl!
//	var playerController = PlayerViewController()
//	private var topQualityFocusGuide = UIFocusGuide()
//	
//	@IBOutlet var progressBar: UIProgressView!
//	@IBOutlet var watchMovieButtonConstraint: NSLayoutConstraint!
//	@IBOutlet var watchMovieButtonBottomConstraint: NSLayoutConstraint!
//	
//	@IBOutlet weak var bg: UIImageView!
//	@IBOutlet weak var poster: UIImageView!
//	@IBOutlet weak var titleRu: UILabel!
//	@IBOutlet weak var titleEn: UILabel!
//	@IBOutlet var intro: FocusableText!
//	
//	@IBOutlet weak var director: UILabel!
//	@IBOutlet weak var cast: UILabel!
//	@IBOutlet weak var country: UILabel!
//	@IBOutlet weak var year: UILabel!
//	@IBOutlet weak var durationGenre: UILabel!
//	@IBOutlet var traslationText: UILabel!
//
//	@IBOutlet weak var rating: UILabel!
//	@IBOutlet weak var stars: CosmosView!
//	@IBOutlet weak var directorLabel: UILabel!
//	@IBOutlet weak var castLabel: UILabel!
//	@IBOutlet var seasonLabel: UILabel!
//	
//	@IBOutlet weak var qualitySegment: UISegmentedControl!
//	@IBOutlet var seasonsScroll: UIScrollView!
//	
//	@IBOutlet weak var playButton: UIButton!
//	@IBOutlet weak var trailerButton: UIButton!
//	@IBOutlet weak var watchedButton: UIButton!
//	@IBOutlet weak var likedButton: UIButton!
//	
//	@IBOutlet weak var watchMovieLabel: UILabel!
//	@IBOutlet weak var watchTrailerLabel: UILabel!
//	@IBOutlet weak var markWatchedLabel: UILabel!
//	@IBOutlet weak var addFavoriteLabel: UILabel!
//	@IBOutlet weak var seasonsScrollView: UIScrollView!
//	@IBOutlet var collectionView: UICollectionView!
//	
//    override func viewDidLoad() {
//        super.viewDidLoad()
//		self.collectionView.registerNib(UINib(nibName: "EpisodeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "episodeCell")
//		self.collectionView.remembersLastFocusedIndexPath = true
//		itemType = ItemType(rawValue: (item?.type)!)
//		isMovie = moviesSet.contains(itemType!) ? true : false
//		setupInterface()
//		fetchItem()
//		setupFocusGuides()
//    }
//	
//	private func setQuality() {
//		QL2("Setting quality for the movie")
//		let qualityIndex = kinoController?.setQualityForAvailableMedia(availableMedia)
//		print("Quality index based on Defaults \(qualityIndex)")
//		qualitySegment.selectedSegmentIndex = qualityIndex!
//		qualityChanged(qualitySegment)
//	}
//	
//	private func setupFocusGuides() {
//		self.view.addLayoutGuide(topQualityFocusGuide)
//		self.topQualityFocusGuide.leftAnchor.constraintEqualToAnchor(self.qualitySegment.leftAnchor).active = true
//		self.topQualityFocusGuide.topAnchor.constraintEqualToAnchor(self.trailerButton.topAnchor).active = true
//		self.topQualityFocusGuide.widthAnchor.constraintEqualToAnchor(self.qualitySegment.widthAnchor).active = true
//		self.topQualityFocusGuide.heightAnchor.constraintEqualToAnchor(self.trailerButton.heightAnchor).active = true
//	}
//	
//	private func setupInterface() {
//		if let item = item, let p = item.posters, let medium = p.medium, let title = item.title {
//			
//			// Постер // Задний план
//			if let URL = NSURL(string: medium) {
//				poster.af_setImageWithURL(URL, placeholderImage: nil, imageTransition: .CrossDissolve(0.2))
//			}
//			if let big = p.big {
//				if let URL = NSURL(string: big) {
//					bg.af_setImageWithURL(URL, placeholderImage: nil, imageTransition: .CrossDissolve(0.2))
//					let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//					let blurView = UIVisualEffectView(effect: blur)
//					blurView.frame = self.bg.bounds
//					self.bg.addSubview(blurView)
//				}
//			}
//			
//			// Название
//			let titleString = title.componentsSeparatedByString(" / ")
//			titleRu.text = titleString[0] // Русское название
//			titleEn.text = titleString.count > 1 ? titleString[1] : "" // Английское
//			// Режиссер
//			if let itemDirector = item.director , itemDirector != "" {
//				director.text = ""
//				let directorsArray  = itemDirector.componentsSeparatedByString(", ") // Делим список по запятой чтоб получить массив актеров
//				if directorsArray.count > 1 {
//					let directorSlice = directorsArray.slice(0,1) // Оставляем только нужное число актеров
//					director.text  = directorSlice.reduce("", combine: {$0! + $1 + "\n"}) // Превращаем массив в текст, с возвратом на следующую строчку
//				} else {
//					director.text = itemDirector
//				}
//				director.sizeToFit()
//			} else {
//				director.text = ""
//				directorLabel.hidden = true
//			}
//			
//			// Актеры
//			if let itemCast = item.cast {
//				cast.text = ""
//				let castArray = itemCast.componentsSeparatedByString(", ") // Делим список по запятой чтоб получить массив актеров
//				let casts = castArray.takeElements(3).reduce("", combine: {$0 + $1 + "\n"}) // Превращаем массив в текст, с возвратом на следующую строчку
//				cast.text = casts
//			} else {
//				cast.text = ""
//				castLabel.hidden = true
//			}
//			
//			// Перевод
//			if let voice = item.voice , voice != "" {
//				traslationText.text = "Аудио / Перевод: \(voice)"
//			}
//		
//			// Описание
//			if let plot = item.plot {
//				intro.text = plot.stripHTML()
//				intro.label = plot.stripHTML()
//				intro.parentView = self
//			}
//			
//			// Рейтинг
//			var ratingString = ""
//			if let imdb = item.imdb_rating , imdb != 0.0 {
//				ratingString = ratingString.stringByAppendingString("IMDB: \(imdb)")
//				stars.rating = Double(imdb)/2
//			} else {
//				if let rating = item.rating {
//					stars.rating = Double(rating)/2
//				}
//			}
//			if let kinopoisk = item.kinopoisk_rating , kinopoisk != 0.0 {
//				if ratingString != "" && item.imdb_rating != 0.0 {
//					ratingString = ratingString.stringByAppendingString(" ● ")
//				}
//				ratingString = ratingString.stringByAppendingString("КиноПоиск: \(kinopoisk)")
//			}
//			rating.text = ratingString
//			// Производство и год
//			if let countries = item.countries {
//				country.text = countries.takeElements(3).reduce("", combine: {$0! + $1.title! + "\n"})
//			}
//			if let date = item.year {
//				year.text = "\(date) г"
//			}
//		}
//	}
//	
//	
//	/**
//	Получаем фильм или сериал по отдельному запросу
//	*/
//	private func fetchItem() {
//		guard let item = item else { return }
//		kinoController = KinoController(item: item, parent: self)
//		// Проверка трейлера
//		if let trailer = item.trailer, let id = trailer.id , id != "" {
//			self.trailerButton.enabled = true
//		} else {
//			self.trailerButton.enabled = false
//		}
//	
//		var genreDurationString = ""
//		var genreString = ""
//		
//		// Жанры
//		if let genres = item.genres {
//			genreString = genres.reduce("", combine: {$0 + $1.title! + " / "})
//			let index = genreString.endIndex.advancedBy(-2)
//			genreString = genreString.substringToIndex(index)
//		}
//		
//		if isMovie { // Item of Movie Type
//			self.watchMovieButtonBottomConstraint.constant = 65 // Pushing all the button further down, because there are no episodes to select
//			API().getMovie(item.id!) { result, error in
//			
//				// Продолжительность фильма
//	
//				if let duration = item.duration, let totalduration = duration.total , totalduration != 0 {
//					let videoDuration = totalduration / 60
//					genreDurationString = genreDurationString.stringByAppendingString("\(videoDuration) мин")
//					genreDurationString = genreDurationString.stringByAppendingString(" ● \(genreString)")
//					self.durationGenre.text = genreDurationString
//				}
//				
//				// Проверка многосерийности
//				if let subtype = self.item?.subtype , subtype == "multi" { // Многосерийный фильма. (e.g 17 мгновений весны)
//		
//					self.playButton.hidden = true
//					self.watchMovieLabel.hidden = true
//					self.watchMovieButtonConstraint.constant = 0
//					self.qualitySegment.hidden = true
//					
//					if let episodes = result?.videos {
//						self.episodes = episodes
//						self.collectionView.reloadData()
//					}
//					
//				} else { // Односерийный фильм
//					
//					guard let video = result?.videos?.first else {
//						log.error("No videos found for this movie")
//						return
//					}
//
//					// Качество
//					let switchAttributes: [NSObject: AnyObject]? = [NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 28.0)!]
//					self.qualitySegment.setTitleTextAttributes(switchAttributes, forState: .Normal)
//					if let files = video.files {
//						self.qualitySegment.replaceSegments(files.map{($0.quality?.rawValue)!})
//						self.availableMedia = files
//						self.movieVideo = video
//					}
//					
//					// Прогресс
//					if video.watching?.status == .Watching, let watchingTime = video.watching?.time {
//						let progress:Float = Float(watchingTime) / Float(video.duration!)
//						self.progressBar.hidden = false
//						self.progressBar.setProgress(progress, animated: true)
//					}
//					
//					// Посмотрел или нет
//					if video.watching?.status == .Watched {
//						self.watchedButton.setImage(UIImage(named: "btn-unwatch"), forState: .Normal)
//						self.markWatchedLabel.text = "Отметить не просмотренным"
//					}
//					
//				}
//				
//			}
//		} else { // item of Series Type
//			playButton.hidden = true
//			watchMovieLabel.hidden = true
//			watchMovieButtonConstraint.constant = 0
//			qualitySegment.hidden = true
//			seasonLabel.hidden = false
//			
//			if let duration = item.duration, let totalduration = duration.total , totalduration != 0 {
//				let videoDuration = totalduration / 60
//				
//				genreDurationString = genreDurationString.stringByAppendingString("\(videoDuration) мин")
//				
//				if let avarageduration = duration.average , avarageduration != 0 {
//					let episodeDuration = avarageduration / 60
//					genreDurationString = genreDurationString.stringByAppendingString(" / \(episodeDuration) мин")
//				}
//
//				genreDurationString = genreDurationString.stringByAppendingString(" ● \(genreString)")
//				self.durationGenre.text = genreDurationString
//			}
//			
//			
//			API().getSeries(item.id!) { result, error in
//				guard var seasons = result?.seasons else {
//					log.error("No seasons found for this TV show")
//					return
//				}
//                
//                for seasonIndex in seasons.indices {
//                    for episodeIndex in seasons[seasonIndex].episodes!.indices {
//                        if (episodeIndex < (seasons[seasonIndex].episodes!.count - 1)) {
//                            seasons[seasonIndex].episodes![episodeIndex].nextVideo = seasons[seasonIndex].episodes![episodeIndex + 1]
//                        }
//                    }
//                }
//                
//				self.seasons = seasons
//				self.setupSeasons(seasons)
//				self.collectionView.reloadData()
//			}
//		}
//	}
//	
//	private func fetchKinopoisk(kinopoiskId: Int, callback: (_ item: Kinopoisk?) -> ()) {
//		API().getKinopoiskItem(kinopoiskId) { result, error in
//			if let result = result {
//				callback(item: result)
//			} else {
//				callback(item: nil)
//			}
//		}
//	}
//	
//	private func setupSeasons(seasons: [Season]) {
//		let segments = seasons.map {String($0.number!)}
//		seasonsSegment = UISegmentedControl(items: segments)
//		seasonsSegment.apportionsSegmentWidthsByContent = true
//		
//		let switchAttributes: [NSObject: AnyObject]? = [NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 30.0)!]
//		seasonsSegment.setTitleTextAttributes(switchAttributes, forState: .Normal)
//		seasonsSegment.addTarget(self, action: #selector(ItemViewController.seasonSegmentChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
//		seasonsScroll.addSubview(self.seasonsSegment)
//		seasonsScroll.contentSize = CGSizeMake(self.seasonsSegment.frame.width+40, self.seasonsSegment.frame.height+10)
//		seasonsSegment.frame.origin.y = 10
//		seasonsSegment.frame.origin.x = 30
//		
//		// Select last available season
//		let lastSeason = seasonsSegment.numberOfSegments-1
//		let season = seasons[lastSeason]
//		seasonsSegment.selectedSegmentIndex = lastSeason
//		selectSeason(season)
//		
//		// Add gesture recognizer
//		let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ItemViewController.toggleSeasonWatched))
//		lpgr.minimumPressDuration = 0.5
//		lpgr.delaysTouchesBegan = true
//		seasonsSegment.addGestureRecognizer(lpgr)
//	}
//	
//	func seasonSegmentChanged(sender : UISegmentedControl) {
//		let season = seasons[sender.selectedSegmentIndex]
//		selectSeason(season)
//	}
//	
//	private func selectSeason(season: Season) {
//		currentSeason = season
//		if let episodes = season.episodes {
//			self.episodes = episodes.reverse()
//			collectionView.reloadData()
//		}
//	}
//	
//	// MARK: - Actions
//	
//	@IBAction func qualityChanged(sender: UISegmentedControl) {
//		selectedMedia = self.availableMedia[sender.selectedSegmentIndex]
//	}
//	
//	@IBAction func playMovie(sender: AnyObject) {
//		if let media = selectedMedia, let videoURL = media.url?.http, let video = movieVideo {
//			if let continueWatching = video.watching?.time , continueWatching > 0 && video.watching?.status != .Watched {
//				let alert = UIAlertController(title: "Что будем делать?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//				let buttonStart = UIAlertAction(title: "Смотреть фильм с начала", style: UIAlertActionStyle.Default) { action in
//					self.kinoController?.playVideo(videoURL, episode: video, season: nil, fromPosition: nil) { position in
//						self.updateMovieProgressForVideo(video, position: position)
//					}
//				}
//				alert.addAction(buttonStart)
//				let buttonContinue = UIAlertAction(title: "Продолжить просмотр", style: UIAlertActionStyle.Default) { action in
//					self.kinoController?.playVideo(videoURL, episode: video, season: nil, fromPosition: continueWatching) { position in
//						self.updateMovieProgressForVideo(video, position: position)
//					}
//				}
//				alert.addAction(buttonContinue)
//				let cancelButton = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Destructive) { (btn) -> Void in }
//				alert.addAction(cancelButton)
//				self.presentViewController(alert, animated: true, completion: nil)
//			} else {
//				self.kinoController?.playVideo(videoURL, episode: video, season: nil, fromPosition: nil) { position in
//					self.updateMovieProgressForVideo(video, position: position)
//				}
//			}
//		}
//	}
//	
//	@IBAction func watchTrailer(sender: AnyObject) {
//		
//		guard let youtubeID = item?.trailer?.id else {
//			log.error("No trailer ID found")
//			return
//		}
//		
//		XCDYouTubeClient.defaultClient().getVideoWithIdentifier(youtubeID) { video, error in
//			if let video = video {
//				if let streamURL = (video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??
//					video.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ??
//					video.streamURLs[XCDYouTubeVideoQuality.Medium360.rawValue] ??
//					video.streamURLs[XCDYouTubeVideoQuality.Small240.rawValue]) {
//						self.playerController = PlayerViewController(videoURL: streamURL)
//						self.presentViewController(self.playerController, animated: true, completion: nil)
//						self.playerController.player?.play()
//				}
//			}
//		}
//	
//	}
//	
//	@IBAction func setMovieWatched(sender: AnyObject) {
//		API().toggleWatched(item!, video: movieVideo, season: nil) { result, error in
//			if let error = error {
//				log.error(error)
//			}
//			if let result = result {
//				if result["watched"].intValue == 1 {
//					self.watchedButton.setImage(UIImage(named: "btn-unwatch"), forState: .Normal)
//					self.markWatchedLabel.text = "Отметить не просмотренным"
//					self.movieVideo?.watching?.status = .Watched
//				} else {
//					self.watchedButton.setImage(UIImage(named: "btn-watch"), forState: .Normal)
//					self.markWatchedLabel.text = "Отметить просмотренным"
//					self.movieVideo?.watching?.status = .Unwatched
//				}
//			}
//		}
//	}
//	
//	@IBAction func likeMovie(sender: AnyObject) {
//		
//	}
//	
//	// MARK: - Collection View
//	
//	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//		return 1
//	}
// 
//	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		return episodes.count
//	}
//	
//	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("episodeCell", forIndexPath: indexPath) as! EpisodeCollectionViewCell
//		let episode = episodes[indexPath.row]
//		cell.progressBar.hidden = true // Default value
//		if let number = episode.number, let title = episode.title {
//			let titleArray = title.componentsSeparatedByString(" / ")
//			if titleArray.count > 1 {
//				let multilineTitle: String = titleArray.reduce("", combine: {$0 + $1 + "\n"})
//				cell.title.text = "\(number). \(multilineTitle)"
//			} else {
//				cell.title.text = "\(number). \(title)"
//			}
//		}
//		if let thumbnail = episode.thumbnail {
//			if let URL = NSURL(string: thumbnail) {
//				cell.thumbnail.af_setImageWithURL(URL, placeholderImage: nil, imageTransition: .CrossDissolve(0.2))
//			}
//		}
//		
//		/*if let watched = episode.watched where watched == 1 {
//			cell.overlay.hidden = false
//			cell.watchedImage.hidden = false
//		}*/
//		
//		if let watching = episode.watching, let status = watching.status {
//			cell.overlay.hidden = status == .Watched ? false : true
//			cell.watchedImage.hidden = status == .Watched ? false : true
//			
//			if status == .Watching {
//				if let duration = episode.duration , duration > 0, let time = watching.time {
//					cell.progressBar.hidden = false
//					let progressed:Float = Float(time) / Float(duration)
//					cell.progressBar.setProgress(progressed, animated: true)
//				} else {
//					cell.progressBar.hidden = true
//				}
//			} else {
//				cell.progressBar.hidden = true
//			}
//			
//		}
//		return cell
//	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//		return UIEdgeInsetsMake(0, 30, 0, 30)
//	}
//	
//	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//		let episode = episodes[indexPath.row]
//		lastSelectedIndex = indexPath
//		
//		guard let files = episode.files else {
//			log.error("No media available for this episode")
//			return
//		}
//		
//		let alert = UIAlertController(title: "Что будем делать?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
//		
//		// Кнопока начать посмотр
//		//let qualityIndex = setQualityForAvailableMedia(files)
//		let qualityIndex = kinoController?.setQualityForAvailableMedia(files)
//		
//		let button = UIAlertAction(title: "Начать просмотр", style: UIAlertActionStyle.default) { action in
//			self.toggleEpisodeWatchedStatus(status: 0) // Если начинаем просмотр - всегда сбрасывать флаг (просмотренный)
//			if let videoURL = files[qualityIndex!].url?.http {
//				self.kinoController?.playVideo(videoURL, episode: episode, season: self.currentSeason, fromPosition: nil) { position in
//					self.updateEpisodeProgressForVideo(episode, position: position)
//				}
//			}
//		}
//		alert.addAction(button)
//		
//		// Кнопочка "Продолжить просмотр"
//		if let continueWatching = episode.watching?.time , continueWatching > 0 && episode.watching?.status != .Watched {
//			let continueButton = UIAlertAction(title: "Продолжить просмотр", style: UIAlertActionStyle.default) { action in
//				if let videoURL = files[qualityIndex!].url?.http {
//					self.kinoController?.playVideo(videoURL, episode: episode, season: nil, fromPosition: continueWatching) { position in
//						self.updateEpisodeProgressForVideo(episode, position: position)
//					}
//				}
//			}
//			alert.addAction(continueButton)
//		}
//		let watchedTitle = episode.watched == 1 ? "Отметить эпизод непросмотренным" : "Отметить эпизод как просмотренный"
//
//		let watchedButton = UIAlertAction(title: watchedTitle, style: UIAlertActionStyle.Default) { (btn) -> Void in
//            self.sendWatchedStatusAndUpdateUI(episode: episode)
//		}
//		alert.addAction(watchedButton)
//		
//		let watchedAllButton = UIAlertAction(title: "Отметить весь сезон как просмотренный", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in
//			//self.toggleAllEpisodesWatched()
//		}
//		alert.addAction(watchedAllButton)
//		let cancelButton = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.destructive) { (btn) -> Void in }
//		alert.addAction(cancelButton)
//		self.present(alert, animated: true, completion: nil)
//	}
//	
//	func toggleSeasonWatched(sender: UILongPressGestureRecognizer) {
//		if let sc = sender.view as? UISegmentedControl , sender.state == .Began {
//			toggleAllEpisodesWatched(sc.selectedSegmentIndex+1)
//		}
//	}
//	
//	func toggleAllEpisodesWatched(season: Int) {
//		
//		let unwatched = self.episodes.filter {$0.watched == -1}
//		let title = unwatched.count == 0 ? "Отметить весь сезон непросмотренным?" : "Отметить весь сезон просмотренным?"
//		
//		let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//		let button = UIAlertAction(title: "Да", style: UIAlertActionStyle.Default) { action in
//			API().toggleWatched(self.item!, video: nil, season: season) { result, error in
//				if let error = error {
//					log.error("Unable to mark season \(error)")
//				}
//				if let result = result , result["watched"] == 1 {
//					self.toggleAllEpisodesVisualStateForStatus(1)
//				} else {
//					self.toggleAllEpisodesVisualStateForStatus(-1)
//				}
//			}
//		}
//		alert.addAction(button)
//		let cancelButton = UIAlertAction(title: "Нет", style: UIAlertActionStyle.Default) { (btn) -> Void in }
//		alert.addAction(cancelButton)
//		self.presentViewController(alert, animated: true, completion: nil)
//	}
//	
//	func updateCellPresentationForStatus(cell: EpisodeCollectionViewCell, status: Int) {
//		cell.overlay.hidden = status == 1 ? false : true
//		cell.watchedImage.hidden = status == 1 ? false : true
//		cell.progressBar.hidden = true
//	}
//	
//	func toggleAllEpisodesVisualStateForStatus(status: Int) {
//		self.episodes = self.episodes.map { (e: Video) -> Video in
//			var s = e
//			s.watched = status == 1 ? 1 : -1
//			s.watching?.status = status == 1 ? .Watched : .Unwatched
//			return s
//		}
//		seasons[seasonsSegment.selectedSegmentIndex].episodes = self.episodes.reverse() // Update the papa!
//		collectionView.reloadData()
//	}
//    
//    func sendWatchedStatusAndUpdateUI(episode: Video) {
//        API().toggleWatched(self.item!, video: episode, season: self.currentSeason.number) { result, error in
//            if let error = error {
//                log.error(error)
//            }
//            if let result = result {
//                self.toggleEpisodeWatchedStatus(status: result["watched"].intValue)
//            }
//        }
//    }
//	
//	func toggleEpisodeWatchedStatus(status: Int) {
//		log.verbose("New episode status \(status)")
//		guard let index = lastSelectedIndex else {
//			log.error("Cannot really handle cell without last selected index")
//			return
//		}
//		if let cell = collectionView.cellForItemAtIndexPath(index) as? EpisodeCollectionViewCell {
//			updateCellPresentationForStatus(cell, status: status)
//			self.episodes[index.row].watched = status == 1 ? 1 : -1
//			self.episodes[index.row].watching?.status = status == 1 ? .Watched : .Unwatched
//		}
//	}
//	
//	func updateMovieProgressForVideo(video: Video, position: NSTimeInterval) {
//		QL2("Stopped playing movie at position: \(position)")
//		let progress:Float = Float(position) / Float(video.duration!)
//		self.movieVideo?.watching?.time = Int(position)
//		self.movieVideo?.watching?.status = .Watching
//		self.progressBar.hidden = false
//		delay(0.5) {
//			self.progressBar.setProgress(progress, animated: true)
//		}
//	}
//	
//	func updateEpisodeProgressForVideo(video: Video, position: NSTimeInterval) {
//		QL2("Stopped playing episode at position: \(position)")
//		let progress:Float = Float(position) / Float(video.duration!)
//		if let i = self.lastSelectedIndex {
//			let cell = self.collectionView.cellForItemAtIndexPath(i) as! EpisodeCollectionViewCell
//			self.episodes[i.row].watching?.time = Int(position)
//			self.episodes[i.row].watching?.status = .Watching // Это для того чтоб возвращаясь к этой серии можно было ее начинать не покидая экрана сериала
//			delay(0.5) {
//				cell.progressBar.hidden = false
//				cell.progressBar.setProgress(progress, animated: true)
//			}
//		}
//        if (progress > 0.9){
//            if (video.watched != 1){
//                self.sendWatchedStatusAndUpdateUI(episode: video)
//            }
//        }
//	}
//	
//	func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
//		return lastSelectedIndex
//	}
//	
//	//func itemDidFinishPlaying(notification: NSNotification) {
//		//print("video finished item")
//		//print(notification)
//	//}
//	
//	// MARK: - Delegate methods
//	
//	override var preferredFocusedView: UIView? {
//		if isMovie {
//			return self.playButton
//		} else {
//			return self.collectionView
//			// FIXME: This is temporary solution. Should focus on first unwatched episode in the unwatched season
//			//return self.likedButton
//		}
//	}
// 
//	/**
//	Custom guides override to able to focus between two otherwise unfocusable views
//	*/
///*	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
//		guard let nextFocusedView = context.nextFocusedView else { return }
//		
//		if let next = context.nextFocusedView as? EpisodeCollectionViewCell {
//			next.setNeedsUpdateConstraints()
//			UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: .CurveEaseIn, animations: {
//				next.thumbnail.transform = CGAffineTransformMakeScale(1.1,1.1)
//				next.overlay.transform = CGAffineTransformMakeScale(1.1,1.1)
//				next.episodeTitleConstraint.constant = 15
//				next.thumbnail.layer.borderColor = UIColor.whiteColor().CGColor
//				next.thumbnail.layer.borderWidth = 2
//				}, completion: { done in
//			})
//		}
//		if let prev = context.previouslyFocusedView as? EpisodeCollectionViewCell {
//			prev.setNeedsUpdateConstraints()
//			UIView.animateWithDuration(0.1, animations: {
//				prev.thumbnail.transform = CGAffineTransformIdentity
//				prev.overlay.transform = CGAffineTransformIdentity
//				prev.episodeTitleConstraint.constant = 3
//				prev.thumbnail.layer.borderWidth = 0
//			})
//		}
//		
//		if isMovie {
//			switch nextFocusedView {
//			case self.qualitySegment:
//				self.topQualityFocusGuide.preferredFocusedView = self.playButton
//			case self.playButton:
//				self.topQualityFocusGuide.preferredFocusedView = self.qualitySegment
//			default:
//				self.topQualityFocusGuide.preferredFocusedView = playButton
//			}
//		}
//	}*/
//	
//}

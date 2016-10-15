//
//  ItemViewController_Extension.swift
//  Kinopub TV
//
//  Created by Peter on 09.10.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import AlamofireImage
import Cosmos
import XCDYouTubeKit

extension ItemViewController: KinoViewable, QualityDefinable {
	
	internal func setQuality() {
		let qualityIndex = setQualityForAvailableMedia(media: availableMedia)
		log.info("Setting quality for movie: \(availableMedia[qualityIndex].quality)")
		qualitySegment.selectedSegmentIndex = qualityIndex
		updateQuality(control: qualitySegment)
	}
	
	internal func prepareForDisplay() {
		guard let id = kinoItem?.id, let type = kinoItem?.type else {
			log.error("No item id or type provided")
			return
		}
		isMovie = moviesSet.contains(type) ? true : false
		
		fetchItem(id: id, type: type) { status in
			switch status {
			case .success(let item):
				if let item = item {
					//self.item = item // Just setting item to a global variable
					// TODO: Hide spinning wheel. Fade in the results
					
					// Плакат
					if let p = item.posters, let image = p.big, let URL = NSURL(string: image) {
						self.poster.af_setImage(withURL: URL as URL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
						// Задний план
						self.bg.af_setImage(withURL: URL as URL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
						let blur = UIBlurEffect(style: UIBlurEffectStyle.dark)
						let blurView = UIVisualEffectView(effect: blur)
						blurView.frame = self.bg.bounds
						self.bg.addSubview(blurView)
					}

					// Название
					if let title = item.title {
						let titleString = title.components(separatedBy: " / ")
						self.titleRu.text = titleString[0] // Русское название
						self.titleEn.text = titleString.count > 1 ? titleString[1] : "" // Английское
					}

					// Перевод
					if let voice = item.voice, voice != "" {
						self.traslationText.text = "Аудио / Перевод: \(voice)"
					}
					
					// Описание
					if let plot = item.plot {
						self.intro.text = plot.stripHTML()
						self.intro.label = plot.stripHTML()
						self.intro.parentView = self
					}

					// Режиссер
					if let director = item.director, director != "" {
						self.director.text = director
					}

					// В ролях
					if let itemCast = item.cast {
						self.cast.text = ""
						let castArray = itemCast.components(separatedBy: ", ") // Делим список по запятой чтоб получить массив актеров
						let casts = castArray.takeElements(element: 3).reduce("", {$0 + $1 + "\n"}) // Превращаем массив в текст, с возвратом на следующую строчку
						self.cast.text = casts
					} else {
						self.cast.text = ""
						self.castLabel.isHidden = true
					}
				
					var genreDurationString = ""
					var genreString = ""
					
					// Жанры
					if let genres = item.genres {
						genreString = genres.flatMap {$0.title!}.joined(separator: " / ")
					}
		
					if let duration = item.duration, let totalduration = duration.total , totalduration != 0 {
						let videoDuration = totalduration / 60
						genreDurationString = genreDurationString.appending("\(videoDuration) мин")
						genreDurationString = genreDurationString.appending(" ● \(genreString)")
						self.durationGenre.text = genreDurationString
					}
					
					// Рейтинг
					// TODO: Implement rating
					var ratingString = ""
					if let imdb = item.imdb_rating, imdb != 0.0 {
						ratingString = ratingString.appending("IMDB: \(imdb)")
						self.stars.rating = Double(imdb)/2
					} else {
						if let rating = item.rating {
							self.stars.rating = Double(rating)/2
						}
					}
					if let kinopoisk = item.kinopoisk_rating, kinopoisk != 0.0 {
						if ratingString != "" && item.imdb_rating != 0.0 {
							ratingString = ratingString.appending(" ● ")
						}
						ratingString = ratingString.appending("КиноПоиск: \(kinopoisk)")
					}
					self.rating.text = ratingString
					// Производство и год
					if let countries = item.countries {
						self.country.text = countries.takeElements(element: 3).reduce("", {$0! + $1.title! + "\n"})
					}
					if let date = item.year {
						self.year.text = "\(date) г"
					}
					
					self.item = item
					self.setupMedia(item: item)
				}
				break
			case .error(let error):
				log.error("Error getting item: \(error)")
				// Maybe show it on the screen
				break
			}
		}
	}
	
	
	/// Проверяет является ли контент фильмом (односерийным или многосерийным) или сериалом. 
	/// Подготавливает интерфейс, сезоны, серии, качество.
	///
	/// - parameter item: Item контент
	private func setupMedia(item: Item) {
		
		if isMovie {
			self.watchMovieButtonBottomConstraint.constant = 65 // Pushing all the button further down, because there are no episodes to select
			if kinoItem?.subtype == .multi { // Многосерийный фильм
				
			} else { // Односерийный фильм
				
				guard let video = item.videos?.first else {
					log.error("No videos found for this movie")
					return
				}
				
				// Качество // Его приходится чуть уменьшать. По дефалту очень большие кнопки
				let switchAttributes = [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 28)]
				self.qualitySegment.setTitleTextAttributes(switchAttributes, for: .normal)
				
				let font = UIFont.systemFont(ofSize: 28.0)
				let attributes = [ NSFontAttributeName : font ]
				self.qualitySegment.setTitleTextAttributes(attributes, for: .selected)
				self.qualitySegment.setTitleTextAttributes(attributes, for: .focused)
				
				if let files = video.files {
					self.qualitySegment.replaceSegments(segments: files.map{($0.quality?.rawValue)!})
					self.availableMedia = files
					self.movieVideo = video
					self.setQuality()
				}
			}

		} else { // Series
			
			self.playButton.isHidden = true
			self.watchMovieLabel.isHidden = true
			self.watchMovieButtonConstraint.constant = 0
			self.qualitySegment.isHidden = true
			self.seasonLabel.isHidden = false
			
			guard var seasons = item.seasons else {
				log.error("No seasons found for this TV show")
				return
			}
		
			for seasonIndex in seasons.indices {
				for episodeIndex in seasons[seasonIndex].episodes!.indices {
					if (episodeIndex < (seasons[seasonIndex].episodes!.count - 1)) {
						seasons[seasonIndex].episodes![episodeIndex].nextVideo = seasons[seasonIndex].episodes![episodeIndex + 1]
					}
				}
			}
			
			self.seasons = seasons
			self.setupSeasons(seasons: seasons)
			self.collectionView.reloadData()
		
		}
	}
	
	internal func updateQuality(control: UISegmentedControl) {
		selectedMedia = self.availableMedia[control.selectedSegmentIndex]
	}
	
	private func setupSeasons(seasons: [Season]) {
		let segments = seasons.map {String($0.number!)}
		seasonsSegment = UISegmentedControl(items: segments)
		seasonsSegment.apportionsSegmentWidthsByContent = true
		
		let switchAttributes = [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 30)]
		seasonsSegment.setTitleTextAttributes(switchAttributes, for: .normal)
		seasonsSegment.addTarget(self, action: #selector(ItemViewController.seasonSegmentChanged(sender:)), for: UIControlEvents.valueChanged)
		seasonsScroll.addSubview(self.seasonsSegment)
		seasonsScroll.contentSize = CGSize(width: self.seasonsSegment.frame.width+40, height: self.seasonsSegment.frame.height+10)
		seasonsSegment.frame.origin.y = 10
		seasonsSegment.frame.origin.x = 30
		
		// Select last available season
		let lastSeason = seasonsSegment.numberOfSegments-1
		let season = seasons[lastSeason]
		seasonsSegment.selectedSegmentIndex = lastSeason
		selectSeason(season: season)
		
		// Add gesture recognizer
		let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ItemViewController.toggleSeasonWatched))
		lpgr.minimumPressDuration = 0.5
		lpgr.delaysTouchesBegan = true
		seasonsSegment.addGestureRecognizer(lpgr)
	}
	
	func seasonSegmentChanged(sender : UISegmentedControl) {
		let season = seasons?[sender.selectedSegmentIndex]
		selectSeason(season: season!)
	}
	
	
	/// Выбор сезона и обновление коллекции
	///
	/// - parameter season: сезон
	private func selectSeason(season: Season) {
		currentSeason = season
		if let episodes = season.episodes {
			self.episodes = episodes.reversed()
			collectionView.reloadData()
		}
	}
	
	/// Принимаем на себя ивент длительного нажатия на номере сезона и отсыламем номер дальше
	///
	/// - parameter sender: разпозноватль жестов
	func toggleSeasonWatched(sender: UILongPressGestureRecognizer) {
		if let sc = sender.view as? UISegmentedControl, sender.state == .began {
			toggleAllEpisodesWatched(season: sc.selectedSegmentIndex+1)
		}
	}
	
	/// Одним махом отмечает все эпизоде в сезоне просмотренными или нет
	///
	/// - parameter season: номер сезона
	func toggleAllEpisodesWatched(season: Int) {
		let unwatched = self.episodes.filter {$0.watched == Status.unwatched.rawValue}
		let title = unwatched.count == 0 ? "Отметить весь сезон непросмотренным?" : "Отметить весь сезон просмотренным?"
		let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
		
		let button = UIAlertAction(title: "Да", style: UIAlertActionStyle.default) { action in
			self.toggleWatched(video: nil, season: season) { status in
				self.episodes = self.episodes.map { (e: Video) -> Video in
					var s = e
					s.watched = status == 1 ? 1 : -1
					s.watching?.status = status == 1 ? .watched : .unwatched
					return s
				}
				self.seasons?[self.seasonsSegment.selectedSegmentIndex].episodes = self.episodes.reversed()
				self.collectionView.reloadData()
			}
		}
		
		alert.addAction(button)
		let cancelButton = UIAlertAction(title: "Нет", style: UIAlertActionStyle.default) { (btn) -> Void in }
		alert.addAction(cancelButton)
		present(alert, animated: true, completion: nil)
	}
	
	/// Обновляет статус о просмотренном / непросмотренном эпизоде на сервере
	///
	/// - parameter episode: Эпизод для которого нужно поменять статус
	func updateWatchStatusForEpisode(episode: Video) {
		toggleWatched(video: episode, season: self.currentSeason?.number) { status in
			self.toggleEpisodeWatchedStatus(status: status)
		}
	}
	
	/// Визуальное обновлние статуса просмотра эпизода.
	///
	/// - parameter status: статус 1 или 0
	func toggleEpisodeWatchedStatus(status: Int) {
		log.debug("New episode status \(status)")
		guard let index = lastSelectedIndex else {
			log.error("Cannot really handle cell without last selected index")
			return
		}
		if let cell = collectionView.cellForItem(at: index as IndexPath) as? EpisodeCollectionViewCell {
			self.episodes[index.row].watched = status == 1 ? Status.watched.rawValue : Status.unwatched.rawValue
			self.episodes[index.row].watching?.status = status == 1 ? .watched : .unwatched
			cell.toggleWatchStatus(status: status)
		}
	}
	
	/// Обновляет маркер о просмотренном времени для всех типов контента
	///
	/// - parameter type:     ItemType контента
	/// - parameter video:    Видео для которого нужно обновить временной маркер
	/// - parameter position: Позиция маркера
	internal func updateWatchingProgressForVideo(type: ItemType, video: Video, position: TimeInterval) {
		
		log.debug("Stopped playing at position: \(position)")
		let progress:Float = Float(position) / Float(video.duration!)
		
		if moviesSet.contains(type) && kinoItem?.subtype != .multi { // Односерийные
			
			self.movieVideo?.watching?.time = Int(position)
			self.movieVideo?.watching?.status = .watching

			delay(delay: 0.5) {
				self.progressBar.isHidden = false
				self.progressBar.setProgress(progress, animated: true)
			}
		
		} else { // Многосерийные
			
			if let index = self.lastSelectedIndex, let cell = collectionView.cellForItem(at: index) as? EpisodeCollectionViewCell {
				episodes[index.row].watching?.time = Int(position)
				episodes[index.row].watching?.status = .watching
				delay(delay: 0.5) {
					cell.progressBar.isHidden = false
					cell.progressBar.setProgress(progress, animated: true)
				}
			}
			
			// Отметить эпизод полностью просмотренным если почти досмотрели до конца
			if progress > 0.9 && video.watched != Status.unwatched.rawValue {
				updateWatchStatusForEpisode(episode: video)
			}
		
		}
		
	}
	
	/// Включает просмотр фильма (с самого начала или продолжить)
	internal func playMovie() {
		
		guard let kinoItem = self.kinoItem else {
			log.error("KinoItem is not available")
			return
		}
		
		if let media = selectedMedia, let videoURL = media.url?.http, let video = movieVideo, let url = URL(string: videoURL) {
			
			print("Current watch time: \( video.watching?.time)")
			print("Movie status: \(video.watching?.status)")
			
			if let continueWatchingPosition = video.watching?.time, continueWatchingPosition > 0 && video.watching?.status != .watched {
				
				let alert = UIAlertController(title: "Что будем делать?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
				
				let buttonContinue = UIAlertAction(title: "Продолжить просмотр", style: UIAlertActionStyle.default) { action in
					self.playVideo(videoURL: url, episode: video, season: nil, fromPosition: continueWatchingPosition) { position in
						self.updateWatchingProgressForVideo(type: kinoItem.type!, video: video, position: position)
					}
				}
				alert.addAction(buttonContinue)
				let buttonStart = UIAlertAction(title: "Смотреть фильм с начала", style: UIAlertActionStyle.default) { action in
					self.playVideo(videoURL: url, episode: video, season: nil, fromPosition: nil) { position in
						self.updateWatchingProgressForVideo(type: kinoItem.type!, video: video, position: position)
					}
				}
				alert.addAction(buttonStart)
				let cancelButton = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.destructive) { (btn) -> Void in }
				alert.addAction(cancelButton)
				self.present(alert, animated: true, completion: nil)
				
			} else { // Мы еще не начинали смотреть этот фильм. Запускаем, минуя менюшку
				
				self.playVideo(videoURL: url as URL, episode: video, season: nil, fromPosition: nil) { position in
					self.updateWatchingProgressForVideo(type: kinoItem.type!, video: video, position: position)
				}
			}
		}
	}
	
	/// Включает просмотр эпизода (многсерийного фильма или сериала). Так же позволяет отметить эпизод просмотренным.
	internal func playEpisode(episode: Video) {
		
		guard let files = episode.files, let kinoItem = kinoItem else {
			log.warning("No media available for this episode")
			return
		}
		
		let alert = UIAlertController(title: "Что будем делать?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
		let qualityIndex = setQualityForAvailableMedia(media: files)
		
		guard let videoURL = files[qualityIndex].url?.http, let url = URL(string: videoURL) else {
			log.error("Unable to select appropriate quality for this episode")
			return
		}
		
		// Добавляем кнопочку "Продолжить просмотр" если не начинали смотреть эпизод до этого.
		if let continueWatchingPosition = episode.watching?.time, continueWatchingPosition > 0 && episode.watching?.status != .watched {
			
			let buttonContinue = UIAlertAction(title: "Продолжить просмотр", style: UIAlertActionStyle.default) { action in
				self.playVideo(videoURL: url, episode: episode, season: nil, fromPosition: continueWatchingPosition) { position in
					self.updateWatchingProgressForVideo(type: kinoItem.type!, video: episode, position: position)
				}
			}
			alert.addAction(buttonContinue)
		}
		
		let buttonStart = UIAlertAction(title: "Смотреть фильм с начала", style: UIAlertActionStyle.default) { action in
			self.playVideo(videoURL: url, episode: episode, season: nil, fromPosition: nil) { position in
				self.updateWatchingProgressForVideo(type: kinoItem.type!, video: episode, position: position)
			}
		}
		alert.addAction(buttonStart)
		
		let cancelButton = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.destructive) { (btn) -> Void in }
		alert.addAction(cancelButton)
		
		self.present(alert, animated: true, completion: nil)
		
		
	}

	
	/// Включаем трейлер к фильму (если доступен)
	internal func playTrailer() {
		guard let youtubeID = item?.trailer?.id else {
			log.error("No trailer ID found")
			return
		}
		log.debug("trailer youtube id: \(youtubeID)")
		XCDYouTubeClient.default().getVideoWithIdentifier(youtubeID) { video, error in
			if let _ = video {
//				var videoURL: URL?
//				for vi in video.streamURLs {
//					if vi.key == XCDYouTubeVideoQuality.HD720.rawValue as AnyHashable {
//						videoURL = vi.value
//						break
//					}
//				}
//				for vi in video.streamURLs {
//					if vi.key == XCDYouTubeVideoQuality.medium360.rawValue as AnyHashable {
//						videoURL = vi.value
//						break
//					}
//				}
//				for vi in video.streamURLs {
//					if vi.key == XCDYouTubeVideoQuality.small240.rawValue as AnyHashable {
//						videoURL = vi.value
//						break
//					}
//				}
//				print(videoURL)
//				guard let url = videoURL else {return}
//				self.playVideo(videoURL: url, episode: nil, season: nil, fromPosition: nil) { _ in }
//				
				
				/*if let streamURL = (video.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ??
					video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ??
					video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]) {
					print("Should start playing trailer")
					self.playVideo(videoURL: streamURL, episode: nil, season: nil, fromPosition: nil) { _ in }
				}*/
			}
		}
	}
	
	
	/// Помечает кино просмотренным
	internal func markWatched() {
	
	}
	
	/// Добавляем в закладки
	internal func addToFavorites() {
	
	}
	
	
}



// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
/// Всяческие делегады collectionView эпизодов
extension ItemViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return episodes.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! EpisodeCollectionViewCell
		let episode = episodes[indexPath.row]
		cell.update(episode: episode)
		return cell
	}
	
	func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
		return lastSelectedIndex
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let episode = episodes[indexPath.row]
		lastSelectedIndex = indexPath
		playEpisode(episode: episode)
	}
	
	// Padding для collectionView. Чтоб эпизоды не клеились к стенке
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
	}
	
}

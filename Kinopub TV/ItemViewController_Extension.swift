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
			guard let seasons = item.seasons else {
				log.error("No seasons found for this TV show")
				return
			}
			episodesStore = seasons
		}
	}
	
	internal func updateQuality(control: UISegmentedControl) {
		selectedMedia = self.availableMedia[control.selectedSegmentIndex]
	}
	
	internal func playMovie() {
		
		if let media = selectedMedia, let videoURL = media.url?.http, let video = movieVideo, let url = NSURL(string: videoURL) {
			
			print("Current watch time: \( video.watching?.time)")
			print("Movie status: \(video.watching?.status)")
			
			if let continueWatchingPosition = video.watching?.time, continueWatchingPosition > 0 && video.watching?.status != .watched {
				
				let alert = UIAlertController(title: "Что будем делать?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
				
				let buttonContinue = UIAlertAction(title: "Продолжить просмотр", style: UIAlertActionStyle.default) { action in
					self.playVideo(videoURL: url as URL, episode: video, season: nil, fromPosition: continueWatchingPosition) { position in
						self.updateWatchingProgressForVideo(video: video, position: position)
					}
				}
				alert.addAction(buttonContinue)
				let buttonStart = UIAlertAction(title: "Смотреть фильм с начала", style: UIAlertActionStyle.default) { action in
					self.playVideo(videoURL: url as URL, episode: video, season: nil, fromPosition: nil) { position in
						self.updateWatchingProgressForVideo(video: video, position: position)
					}
				}
				alert.addAction(buttonStart)
				let cancelButton = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.destructive) { (btn) -> Void in }
				alert.addAction(cancelButton)
				self.present(alert, animated: true, completion: nil)
				
			} else {
				self.playVideo(videoURL: url as URL, episode: video, season: nil, fromPosition: nil) { position in
					self.updateWatchingProgressForVideo(video: video, position: position)
				}
			}
		}
	}
	
	private func updateWatchingProgressForVideo(video: Video, position: TimeInterval) {
		movieVideo?.watching?.time = Int(position) // Updating time marker without leaving the view
	}


	internal func playTrailer() {
		guard let youtubeID = item?.trailer?.id else {
			log.error("No trailer ID found")
			return
		}
		log.debug("trailer youtube id: \(youtubeID)")
		XCDYouTubeClient.default().getVideoWithIdentifier(youtubeID) { video, error in
			if let video = video {
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
	
	internal func markWatched() {
	
	}
	
	internal func addToFavorites() {
	
	}
	
	
}

extension ItemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return episodes.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "episodeCell", for: indexPath) as! EpisodeCollectionViewCell
		let episode = episodes[indexPath.row]
		cell.update(episode: episode)
		return cell
	}
	
	
}

//
//  Kinopub.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SwiftyJSON
import ObjectMapper
import AVFoundation
import AVKit
import PMKVObserver
import AlamofireImage
import Alamofire

// List protocol

enum ItemsResponse {
	case success(items: [Item]?, pagination: Pagination?)
	case error(error: NSError)
}

protocol KinoListable: Connectable {
	func fetchItems(for type: ItemType, page: Int?, callback: @escaping (_ response: ItemsResponse) -> ()) -> Void
	func fetchItems(for pick: Pick, callback: @escaping (_ response: ItemsResponse) -> ()) -> Void
}

extension KinoListable {
	
	func fetchItems(for pick: Pick, callback: @escaping (_ response: ItemsResponse) -> ()) {
		let parameters: Dictionary<String, AnyObject> = [
			"id": pick.id as AnyObject
		]
		let request = Request(type: .resource, resourceURL: "/collections/view", method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			self.processItemsResponse(for: result, error: error) { response in
				callback(response)
			}
		}
	}
	
	func fetchItems(for type: ItemType, page: Int? = 1, callback: @escaping (_ response: ItemsResponse) -> ()) {
		let parameters: Dictionary<String, AnyObject> = [
			"type": type.rawValue as AnyObject,
			"perpage": 50 as AnyObject,
			"page": page as AnyObject
		]
		
		let request = Request(type: .resource, resourceURL: "/items", method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			self.processItemsResponse(for: result, error: error) { response in
				callback(response)
			}
		}
	}
	
	fileprivate func processItemsResponse(for result: JSON?, error: NSError?, callback: @escaping (_ response: ItemsResponse) -> ()) {
		switch (result, error) {
		case(let result?, _):
			if result["status"] == 200 {
				
				if let items = Mapper<Item>().mapArray(JSONObject: result["items"].arrayObject),
					let pagination = Mapper<Pagination>().map(JSONObject: result["pagination"].object)
				{
					callback(.success(items: items, pagination: pagination))
				} else if let items = Mapper<Item>().mapArray(JSONObject: result["items"].arrayObject) { // Case of picks, where there is no pagination
					callback(.success(items: items, pagination: nil))
				} else {
					log.warning("Problem mapping items. Returning nil")
					callback(.success(items: nil, pagination: nil))
				}
			}
		case(_, let error?):
			log.error("Error accessing the service \(error)")
			callback(.error(error: error))
			break
		default: break
		}
	}
}

// Single Item protocol

enum ItemResponse {
	case success(item: Item?)
	case error(error: NSError)
}

protocol KinoViewable: class, Connectable, QualityDefinable {
	var playerController: AVPlayerViewController! {get set}
	var item: Item? {get set}
	var kinoItem: KinoItem? {get set} // Priliminary item (before we got a response from the sever)
	func fetchItem(id: Int, type: ItemType, callback: @escaping (_ response: ItemResponse) -> ()) -> Void
	func playVideo(with videoURL: URL, episode: Video?, season: Season?, fromPosition: Int?, callback: @escaping (_ position: TimeInterval) -> ()) -> Void
	func toggleWatched(video: Video?, season: Int?, callback: @escaping (_ status: Int) -> ()) -> Void
}

extension KinoViewable where Self: UIViewController {
	
	/**
	Log watchable item from the server. May be any item (Movie, Series, etc...)
	- parameter id:				id of the item
	- parameter type:			type of the Item
	- parameter callback:	response back to the view
	*/
	func fetchItem(id: Int, type: ItemType, callback: @escaping (_ response: ItemResponse) -> ()) {
		let request = Request(type: .resource, resourceURL: "/items/\(id)", method: .get, parameters: nil)
		performRequest(resource: request) { result, error in
			switch (result, error) {
			case(let result?, _):
				if result["status"] == 200 {
					if let item = Mapper<Item>().map(JSONObject: result["item"].dictionaryObject) {
						callback(.success(item: item))
					} else {
						callback(.success(item: nil))
					}
				}
			case(_, let error?):
				log.error("Error accessing the service \(error)")
				callback(.error(error: error))
				break
			default: break
			}
		}
	}
	/**
	Protocol method for playing video from the beginning or certain position in time
	- parameter videoURL:			URL for the video
	- parameter episode:			episode id
	- parameter season:				season (if available)
	- parameter fromPosition:	starting position
	- parameter callback:			callback to update watched progress in the view controller
	*/
	func playVideo(with videoURL: URL, episode: Video?, season: Season?, fromPosition: Int?, callback: @escaping (_ position: TimeInterval) -> ()) {
		
		let playerItem = AVPlayerItem(url: videoURL)
		let player = AVPlayer(playerItem: playerItem)
		
		player.allowsExternalPlayback = true
		playerController = AVPlayerViewController()
		playerController.player = player
		
		/*_ = KVObserver(object: playerItem, keyPath: "status", options: NSKeyValueObservingOptions()) { object, _, kvo in
		print("Current status: \(object.status.rawValue)")
		kvo.cancel()
		}*/
		
		// Next episode proposal
		if let _ = season, let episode = episode, let nextEpisode = episode.nextVideo {
			if let imageUrl = URL(string: nextEpisode.thumbnail!) {
				let qualityIndex = setQualityForAvailableMedia(media: nextEpisode.files!)
				guard let videoURL = nextEpisode.files?[qualityIndex].url?.http, let url = URL(string: videoURL) else {
					log.error("Unable to select appropriate quality for this episode")
					return
				}
				getRemoteImage(for: imageUrl) { image in
					let contentProposal = AVContentProposal(contentTimeForTransition: kCMTimeZero, title: nextEpisode.title!, previewImage: image)
					contentProposal.url = url
					playerItem.nextContentProposal = contentProposal
				}
			}
		}
		
		_ = KVObserver(object: player, keyPath: "rate", options: NSKeyValueObservingOptions()) { object, _, kvo in
			if object.rate == 0 {
				let duration: TimeInterval = CMTimeGetSeconds((object.currentItem?.duration)!)
				let currentTime: TimeInterval = CMTimeGetSeconds(object.currentTime())
				// 15 seconds error margin.
				if (currentTime + 15) >= duration {
					log.verbose("Movie ended :-)")
					// TODO: Switch to next episode
					self.playerController.dismiss(animated: true, completion: nil)
				}
				self.logCurrentPosition(video: episode, season: season, time: currentTime)
				callback(currentTime)
			} else if object.rate > 0 {
				log.verbose("Resume playing")
			}
		}
		
		present(self.playerController!, animated: true) {
			if let position = fromPosition {
				let seconds = Float64(position)
				let targetTime = CMTimeMakeWithSeconds(seconds, 1)
				self.playerController.player?.seek(to: targetTime)
			}
			self.playerController.player?.play()
		}
	}
	
	func getRemoteImage(for url: URL, callback: @escaping (_ image: UIImage) -> ()) {
		Alamofire.request(url).responseImage { response in
			if let image = response.result.value {
				callback(image)
			}
		}
	}
	
//	fileprivate func findNextEpisode(for episode: Video, season: Season) -> Video {
//		
//	}
	
	/**
	Logs currently playing item's time to a stopped position. So it can be resumed later
	- parameter video:	episode to save
	- parameter season:	season (if available)
	- parameter time:		currently elapsed time
	*/
	private func logCurrentPosition(video: Video?, season: Season?, time: TimeInterval) {
		guard let id = kinoItem?.id else {
			log.error("Id is not set. Nothing to log")
			return
		}
		
		var parameters: Dictionary<String, AnyObject> = [
			"id": id as AnyObject,
			"time": Int(time) as AnyObject
		]
		if let video = video {
			parameters["video"] = video.number as AnyObject?
		} else {
			parameters["video"] = 1 as AnyObject?
		}
		if let season = season {
			parameters["season"] = season.number as AnyObject?
		}
		
		let request = Request(type: .resource, resourceURL: "/watching/marktime", method: .get, parameters: parameters)
//		log.debug(request)
		performRequest(resource: request) { result, error in
			switch (result, error) {
			case(let result?, _):
				log.verbose(result)
				break
			case(_, let error?):
				log.error("Error accessing the service \(error)")
				break
			default: break
			}
		}
	}
	
	func toggleWatched(video: Video?, season: Int?, callback: @escaping (_ status: Int) -> ()) {
		guard let id = kinoItem?.id else {
			log.error("Id is not set. Nothing to log")
			return
		}
		var parameters: Dictionary<String, AnyObject> = [
			"id": id as AnyObject
		]
		if let video = video {
			parameters["video"] = video.number as AnyObject?
		}
		if let season = season {
			parameters["season"] = season as AnyObject?
		}
		let request = Request(type: .resource, resourceURL: "/watching/toggle", method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			switch (result, error) {
			case(let result?, _):
				if result["watched"] == 1 {
					callback(1)
				} else if result["watched"] == 0 {
					callback(0)
				}
				break
			case(_, let error?):
				log.error("Error accessing the service \(error)")
				break
			default: break
			}
		}
	}
	
}

protocol QualityDefinable {
	func setQualityForAvailableMedia(media: [File]) -> Int
}

extension QualityDefinable {
	
	func setQualityForAvailableMedia(media: [File]) -> Int {
		guard let defaultQuality = Defaults[.defaultQuality], let quality = Quality(rawValue: defaultQuality) else {
			log.warning("Quality not defined in user defaults")
			return 0
		}
		var index = 0
		let files = media.map{($0.quality?.rawValue)!}
		if files.count == 1 && files[0] == "3D" {
			return index
		}
		switch(quality) {
		case .sd:
			index = 0
			break
		case .hd:
			var o = 0
			for (i, file) in files.enumerated() {
				if file == defaultQuality {
					o = i
					break
				} else {
					o = media.count-1
				}
			}
			index = o
			break
		case .fullHd:
			index = media.count-1
			break
		default:
			index = media.count-1
			break
		}
		return index
	}
}

// For launching media direction from List Views

protocol KinoPlayable {
	func playMedia()
}

extension KinoPlayable {
	func playMedia() {
		
	}
}
















//
//  KinopubTV.swift
//  Kinopub TV
//
//  Created by Peter on 15.10.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
import AVFoundation
import AVKit

enum TVChannelsResponse {
	case success(channels: [TVChannel]?)
	case error(error: NSError)
}

protocol TVViewable: class, Connectable {
	var playerController: AVPlayerViewController! {get set}
	func fetchChannels(callback: @escaping (_ response: TVChannelsResponse) -> ()) -> Void
	func watchChannel(url: URL) -> Void
}

extension TVViewable where Self: UIViewController {

	func fetchChannels(callback: @escaping (_ response: TVChannelsResponse) -> ()) {
		let request = Request(type: .resource, resourceURL: "/tv", method: .get, parameters: nil)
		
		performRequest(resource: request) { result, error in
			switch (result, error) {
			case(let result?, _):
				if let channels = Mapper<TVChannel>().mapArray(JSONObject: result["channels"].arrayObject) {
					callback(.success(channels: channels))
				}
				break
			case(_, let error?):
				log.error("Error accessing the service \(error)")
				callback(.error(error: error))
				break
			default: break
			}
		}
	}
	
	func watchChannel(url: URL) {
	
		let playerItem = AVPlayerItem(url: url)
		let player = AVPlayer(playerItem: playerItem)

		player.allowsExternalPlayback = true
		playerController = AVPlayerViewController()
		playerController.player = player

		present(self.playerController!, animated: true) {
			self.playerController.player?.play()
		}
	}
	
}

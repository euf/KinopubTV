//
//  APIDelegatable.swift
//  Kinopub TV
//
//  Created by Peter on 25.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


protocol APIDelegatable {
	func getFanArtBy(imdb id: Int, callback: @escaping (_ response: URL?) -> ()) -> Void
}

extension APIDelegatable {
	
	func getFanArtBy(imdb id: Int, callback: @escaping (_ response: URL?) -> ()) {
//		let headers = [
//			"Authorization": "Bearer 68f4613d4f8645014b140e46d11dbd79f13478988a2fe071ee8f0a903e21c8e5",
//			"Content-type": "application/json",
//			"trakt-api-key": "126451395c4aee81a7ff82b38744b53acafefcc67d8bb4537cc983792c93e1f5",
//			"trakt-api-version": "2"
//		]
		let charactersCount = String(id).characters.count
		let imdb = charactersCount > 6 ? "tt"+String(id) : "tt0"+String(id)
		Alamofire.request(Config.guideBox.base+Config.guideBox.key+"/search/id/imdb/\(imdb)", parameters: nil).responseJSON { response in
			switch response.result {
			case .success(let data):
				
				let result = JSON(data)
				let tvdb = result["tvdb"]
//				log.debug(tvdb)
				Alamofire.request("http://webservice.fanart.tv/v3/tv/\(tvdb)", parameters: ["api_key": "172e8ebb6f757378c74cd78712b5978f"]).responseJSON { response in
					switch response.result {
					case .success(let data):
						
						var url: URL?
						let result = JSON(data)
						
						if result["hdclearart"][0]["url"].null == nil {
							if let u = URL(string: result["hdclearart"][0]["url"].string!) {
								url = u
								callback(url)
							}
						} else {
							if result["clearart"][0]["url"].null == nil {
								if let u = URL(string: result["clearart"][0]["url"].string!) {
									url = u
									callback(url)
								}
							}
						}
						// another callback here?
						
					case .failure(let error):
						log.error("Error calling TVMaze: \(error)")
					}
				}
				
			case .failure(let error):
				log.error("Error calling TVMaze: \(error)")
			}
		}
		
		// First we call TV Maze by IMDB
		// We get TVDB ID of the show
		// Request FanArt for clear art
		
	}
}

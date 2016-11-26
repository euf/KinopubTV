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

enum ItemsResponse {
	case success(items: [Item]?, pagination: Pagination?)
	case error(error: NSError)
}

protocol KinoListable: Connectable {
	func fetchItems(for type: ItemType, page: Int?, callback: @escaping (_ response: ItemsResponse) -> ()) -> Void
	func fetchItems(for pick: Pick, callback: @escaping (_ response: ItemsResponse) -> ()) -> Void
	func getFeaturedMovies(callback: @escaping (_ response: ItemsResponse) -> ()) -> Void
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
	
	func getFeaturedMovies(callback: @escaping (_ response: ItemsResponse) -> ()) {
		let parameters: Dictionary<String, AnyObject> = [
			"type": ItemType.movies.getValue() as AnyObject,
			"perpage": 20 as AnyObject,
			"page": 1 as AnyObject
		]
		
		let request = Request(type: .resource, resourceURL: "/items/fresh", method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			self.processItemsResponse(for: result, error: error) { response in
				callback(response)
			}
		}
	}
	
	func getPopularTVShows(callback: @escaping (_ response: ItemsResponse) -> ()) {
		let parameters: Dictionary<String, AnyObject> = [
			"type": ItemType.shows.getValue() as AnyObject,
			"perpage": 30 as AnyObject,
			"sort": "-watchers" as AnyObject
		]
		let request = Request(type: .resource, resourceURL: "/items", method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			self.processItemsResponse(for: result, error: error) { response in
				
				
				
				callback(response)
			}
		}
	}
	
	fileprivate func fetchMovieResource(for id: String, callback: @escaping (_ response: JSON?) -> ()) {
		let parameters: Dictionary<String, AnyObject> = [
			"api_key": Config.themoviedb.key as AnyObject,
			"external_source": "imdb_id" as AnyObject,
		]
		let request = Request(type: .movieDB, resourceURL: "/find/"+id, method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			callback(result)
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
















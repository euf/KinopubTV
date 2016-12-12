//
//  Bookmarkable.swift
//  Kinopub TV
//
//  Created by Peter on 11.12.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper
import Alamofire

enum BookmarksResponse {
	case success(items: [Bookmark]?)
	case error(error: NSError)
}

protocol Bookmarkable: KinoListable {
	func fetchBookmarks(callback: @escaping (_ response: BookmarksResponse) -> ()) -> Void
	func fetchItems(for bookmarkId: Int, page: Int, callback: @escaping (_ response: ItemsResponse) -> ()) -> Void
}

extension Bookmarkable {
	
	func fetchBookmarks(callback: @escaping (_ response: BookmarksResponse) -> ()) {
		let request = Request(type: .resource, resourceURL: "/bookmarks", method: .get, parameters: [:])
		performRequest(resource: request) { result, error in
			switch (result, error) {
			case(let result?, _):
				if result["status"] == 200 {
					if let items = Mapper<Bookmark>().mapArray(JSONObject: result["items"].arrayObject) {
						callback(.success(items: items))
					} else {
						log.warning("Problem mapping bookmarks. Returning nil")
						callback(.success(items: nil))
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
	
	func fetchItems(for bookmarkId: Int, page: Int, callback: @escaping (_ response: ItemsResponse) -> ()) {
		let parameters: Dictionary<String, AnyObject> = [
			"perpage": 50 as AnyObject
		]
		let request = Request(type: .resource, resourceURL: "/bookmarks/"+String(bookmarkId), method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			self.processItemsResponse(for: result, error: error) { response in
				callback(response)
			}
		}
	}
	
}

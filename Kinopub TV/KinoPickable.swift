//
//  Kinopickable.swift
//  Kinopub TV
//
//  Created by Peter on 13.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import ObjectMapper

enum PicksResponse {
	case success(items: [Pick]?, pagination: Pagination?)
	case error(error: NSError)
}

protocol KinoPickable: Connectable {
	func fetchPicks(page: Int?, callback: @escaping (_ response: PicksResponse) -> ()) -> Void
}

extension KinoPickable {
	func fetchPicks(page: Int? = 1, callback: @escaping (_ response: PicksResponse) -> ()) {
		let parameters: Dictionary<String, AnyObject> = [
			"perpage": 50 as AnyObject,
			"page": page as AnyObject
		]
		let request = Request(type: .resource, resourceURL: "/collections", method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			switch (result, error) {
			case(let result?, _):
				if result["status"] == 200 {
					if let items = Mapper<Pick>().mapArray(JSONObject: result["items"].arrayObject), let pagination = Mapper<Pagination>().map(JSONObject: result["pagination"].object) {
						callback(.success(items: items, pagination: pagination))
					} else {
						log.warning("Problem mapping picks. Returning nil")
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
}

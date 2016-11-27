//
//  KinoSortable.swift
//  Kinopub TV
//
//  Created by Peter on 27.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import ObjectMapper

protocol KinoSortable: Connectable {
	func getGenres(for type: GenreType, callback: @escaping (_ response: [Genre]) -> ())
}

extension KinoSortable {
	func getGenres(for type: GenreType, callback: @escaping (_ response: [Genre]) -> ()) {
		let parameters: Dictionary<String, AnyObject> = [
			"type": type.rawValue as AnyObject
		]
		let request = Request(type: .resource, resourceURL: "/genres", method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			switch (result, error) {
			case(let result?, _):
				if result["status"] == 200 {
					if let items = Mapper<Genre>().mapArray(JSONObject: result["items"].arrayObject) {
						callback(items)
					}
				}
			case(_, let error?):
				log.error("Error accessing the service \(error)")
				break
			default: break
			}
			
		}
	}
}

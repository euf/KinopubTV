//
//  Kinosearchable.swift
//  Kinopub TV
//
//  Created by Peter on 26.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation

protocol KinoSearchable: Connectable, KinoListable {
	func search(for text: String, callback: @escaping (_ response: ItemsResponse) -> ())
}

extension KinoSearchable {
	func search(for text: String, callback: @escaping (_ response: ItemsResponse) -> ()) {
		
		let parameters: Dictionary<String, AnyObject> = [
			"title": text as AnyObject,
			"perpage": 50 as AnyObject,
			"page": 1 as AnyObject
		]
		
		let request = Request(type: .resource, resourceURL: "/items", method: .get, parameters: parameters)
		performRequest(resource: request) { result, error in
			self.processItemsResponse(for: result, error: error) { response in
				callback(response)
			}
		}
	}
}

//
//  Pick.swift
//  Kinopub TV
//
//  Created by Peter on 12.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import ObjectMapper

struct Pick: Mappable {
	
	var id: Int?
	var title: String?
	var views: Int?
	var watchers: Int?
	var posters: Poster?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		id <- map["id"]
		title <- map["title"]
		views <- map["views"]
		watchers <- map["watchers"]
		posters <- map["posters"]
	}
}

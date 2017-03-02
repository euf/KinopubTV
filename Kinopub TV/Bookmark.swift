//
//  Bookmark.swift
//  Kinopub TV
//
//  Created by Peter on 11.12.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import ObjectMapper

struct Bookmark: Mappable {
	
	var id: Int?
	var title: String?
	var views: Int?
	var count: Int?
	var created: Date?
	var updated: Date?
	
	init?(map: Map){}

	mutating func mapping(map: Map) {
		id <- map["id"]
		title <- map["title"]
		views <- map["views"]
		count <- (map["count"], IntTransform())
		created <- (map["created"], DateIntervalTransform())
		updated <- (map["updated"], DateIntervalTransform())
	}
	
}

//
//  TVChannel.swift
//  Kinopub TV
//
//  Created by Peter on 15.10.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import ObjectMapper

struct TVChannel: Mappable {
	
	var id: String?
	var title: String?
	var name: String?
	var logo: TVLogo?
	var stream: String?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		id <- map["id"]
		title <- map["title"]
		name <- map["name"]
		logo <- map["logos"]
		stream <- map["stream"]
	}
}

struct TVLogo: Mappable {
	
	var small: String?
	var medium: String?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		small <- map["s"]
		medium <- map["m"]
	}
	
}

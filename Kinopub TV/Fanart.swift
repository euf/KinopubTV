//
//  Fanart.swift
//  Kinopub TV
//
//  Created by Peter on 25.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import ObjectMapper

struct Fanart: Mappable {
	
	var name: String?
	var clearArt: String?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		name <- map["name"]
		clearArt <- map["clearArt"]
	}
	
}

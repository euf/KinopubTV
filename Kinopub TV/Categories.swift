//
//  Categories.swift
//  Kinopub
//
//  Created by Peter on 29/06/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import ObjectMapper

struct Type: Mappable {
	
	var id: String?
	var title: String?
	
	init?(map: Map){}
	
	mutating func mapping(map: Map) {
		id <- map["id"]
		title <- map["title"]
	}
}

struct Country: Mappable {
	
	var id: Int?
	var title: String?
	
	init?(map: Map){}
	
	mutating func mapping(map: Map) {
		id <- map["id"]
		title <- map["title"]
	}
}

struct Genre: Mappable {
	
	var id: Int?
	var title: String?
	var type: GenreType?
	
	init?(map: Map){}
	
	init() {}
	
	let convertGenre = TransformOf<GenreType, String>(fromJSON: { (value: String?) -> GenreType? in
		guard let genre = value else { return nil }
		return GenreType(rawValue: genre)
		}, toJSON: { (value: GenreType?) -> String? in
			return nil
	})
	
	mutating func mapping(map: Map) {
		id <- map["id"]
		title <- map["title"]
		type <- map["type"]
	}
}


extension Genre: Equatable {}

func ==(lhs: Genre, rhs: Genre) -> Bool {
	return lhs.id == rhs.id
}

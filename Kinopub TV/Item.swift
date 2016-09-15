//
//  Item.swift
//  Kinopub
//
//  Created by Peter on 29/06/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import ObjectMapper

struct KinoItem {
	var id: Int?
	var type: ItemType?
	var subtype: ItemSubType? = nil
}

class Item: Mappable {
	
	var id: Int?
	var type: String?
	var subtype: String?
	var title: String?
	var year: Int?
	var cast: String?
	var director: String?
	var genres: Array<Genre>?
	var countries: Array<Country>?
	var plot: String?
	var voice: String?
	var duration: Duration?
	var imdb: Int?
	var imdb_rating: Float?
	var imdb_votes: Int?
	var kinopoisk: Int?
	var kinopoisk_rating: Float?
	var kinopoisk_votes: Int?
	var rating: Int?
	var rating_votes: Int?
	var rating_percentage: Float?
	var views: Int?
	var posters: Poster?
	var trailer: Trailer?
	var in_watchlist: Bool?
	
	// Movies only
	var videos: Array<Video>?
	
	// Series only
	var watched: Int? // Used only when requesting unwatched stuff
	var new: Int? // Used only when requesting unwatched stuff
	var total: Int? // Used only when requesting unwatched stuff
	var seasons: Array<Season>?
	
	required init?(map: Map) {}
	
	let convertToFloat = TransformOf<Float, String>(fromJSON: { (value: String?) -> Float? in
		guard let myFloat = value else { return nil }
		return Float(myFloat)
		}, toJSON: { (value: Float?) -> String? in
			return nil
	})
	
	func mapping(map: Map) {
		id <- map["id"]
		type <- map["type"]
		subtype <- map["subtype"]
		title <- map["title"]
		year <- map["year"]
		cast <- map["cast"]
		director <- map["director"]
		genres <- map["genres"]
		countries <- map["countries"]
		plot <- map["plot"]
		voice <- map["voice"]
		duration <- map["duration"]
		imdb <- map["imdb"]
		imdb_rating <- map["imdb_rating"]
		imdb_votes <- map["imdb_votes"]
		kinopoisk <- map["kinopoisk"]
		kinopoisk_rating <- map["kinopoisk_rating"]
		kinopoisk_votes <- map["kinopoisk_votes"]
		rating <- map["rating"]
		rating_votes <- map["rating_votes"]
		rating_percentage <- map["rating_percentage"]
		views <- map["views"]
		trailer <- map["trailer"]
		posters <- map["posters"]
		in_watchlist <- map["in_watchlist"]
		videos <- map["videos"] // For Movies only
		seasons <- map["seasons"]
		new <- map["new"]
		total <- map["total"]
		watched <- map["watched"]
	}
}

/*class Series: Item, CustomStringConvertible, CustomDebugStringConvertible {

var watched: Int? // Used only when requesting unwatched stuff
var new: Int? // Used only when requesting unwatched stuff
var total: Int? // Used only when requesting unwatched stuff
var seasons: Array<Season>?

var description: String {
return "Item title: \(title)"
}
var debugDescription: String {
return "Item title: \(title)"
}

required init?(_ map: Map) {
super.init(map)
}

override func mapping(map: Map) {
super.mapping(map)
seasons <- map["seasons"]
new <- map["new"]
total <- map["total"]
watched <- map["watched"]
}
}*/

struct Season: Mappable {
	
	var title: String?
	var number: Int?
	var episodes: [Video]?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		title <- map["title"]
		number <- map["number"]
		episodes <- map["episodes"]
	}
}

/*class Movie: Item {

var videos: Array<Video>?

required init?(_ map: Map) {
super.init(map)
}

override func mapping(map: Map) {
super.mapping(map)
videos <- map["videos"]
}
}*/

struct Video: Mappable {
	
	var id: Int?
	var title: String?
	var thumbnail: String?
	var duration: Int?
	var tracks: String?
	var watched: Int?
	var watching: Watching?
	var number: Int?
	var subtitles: [Subtitle]?
	var files: [File]?
	
	private var _nextVideo: [Video]?
	var nextVideo: Video? {
		set {
			_nextVideo = [newValue!]
		}
		get {
			return _nextVideo?.first
		}
	}
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		id <- map["id"]
		title <- map["title"]
		thumbnail <- map["thumbnail"]
		duration <- map["duration"]
		tracks <- map["tracks"]
		watched <- map["watched"]
		watching <- map["watching"]
		number <- map["number"]
		subtitles <- map["subtitles"]
		files <- map["files"]
	}
}

struct Subtitle: Mappable {
	
	var lang: String?
	var shift: Int?
	var embed: Bool?
	var url: String?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		lang <- map["lang"]
		shift <- map["shift"]
		embed <- map["embed"]
		url <- map["url"]
	}
}


struct File: Mappable {
	
	var w: Int?
	var h: Int?
	var quality: Quality?
	var url: MediaURL?
	
	init?(map: Map) {}
	
	let convertQuality = TransformOf<Quality, String>(fromJSON: { (value: String?) -> Quality? in
		guard let myQuality = value else { return nil }
		return Quality(rawValue: myQuality)
		}, toJSON: { (value: Quality?) -> String? in
			return nil
	})
	
	mutating func mapping(map: Map) {
		w <- map["w"]
		h <- map["h"]
		quality <- (map["quality"], convertQuality)
		url <- map["url"]
	}
}

struct Trailer: Mappable {
	var id: String?
	var url: String?
	var thumbnail: String?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		id <- map["id"]
		url <- map["url"]
		thumbnail <- map["thumbnail"]
	}
}

struct MediaURL: Mappable {
	
	var http: String?
	var hls: String?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		http <- map["http"]
		hls <- map["hls"]
	}
}

struct Poster: Mappable {
	
	var small: String?
	var medium: String?
	var big: String?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		small <- map["small"]
		medium <- map["medium"]
		big <- map["big"]
	}
}

struct Duration: Mappable {
	
	var average: Int?
	var total: Int?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		average <- map["average"]
		total <- map["total"]
	}
}

struct Watching: Mappable {
	
	var status: Status?
	var time: Int?
	
	let convertStatus = TransformOf<Status, Int>(fromJSON: { (value: Int?) -> Status? in
		guard let myStatus = value else { return nil }
		return Status(rawValue: myStatus)
		}, toJSON: { (value: Status?) -> Int? in
			return nil
	})
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		status <- (map["status"], convertStatus)
		time <- map["time"]
	}
}

struct Pagination: Mappable {
	
	var current: Int?
	var total: Int?
	var perpage: Int?
	
	init?(map: Map) {}
	mutating func mapping(map: Map) {
		current <- map["current"]
		total <- map["total"]
		perpage <- map["perpage"]
	}
}




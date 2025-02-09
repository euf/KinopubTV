//
//  enums.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation

enum SortOption: String, CustomStringConvertible {
	
	case id
	case year
	case title
	case created
	case updated
	case rating
	case views
	case watchers
	
	static let all = [year, title, created, updated, rating, views, watchers]
	
	func name() -> String {
		switch self {
		case .id:
			return "По Id"
		case .year:
			return "По году выпуска"
		case .title:
			return "По названию"
		case .created:
			return "По дате добавления"
		case .updated:
			return "По дате обновления"
		case .rating:
			return "По рейтингу"
		case .views:
			return "По просмотрам"
		case .watchers:
			return "По кол-ву смотрящих"
		}
	}
	
	func desc() -> String {
		return "-\(self.rawValue)"
	}
	
	func asc() -> String {
		return self.rawValue
	}
	
	var description: String {
		return self.rawValue
	}
}

enum SortDirection: String, CustomStringConvertible {
	case asc = ""
	case desc = "-"
	init() {
		self = .asc
	}
	var description: String {
		return self.rawValue
	}
}

enum Status: Int {
	case unwatched = -1
	case watching = 0
	case watched = 1
}

enum Quality: String {
	case sd = "480p"
	case hd = "720p"
	case fullHd = "1080p"
	case k4 = "2160p"
	case d3 = "3D"
	static let All = [sd, hd, fullHd]
}

enum ItemSubType: String {
	case multi
}

enum GenreType: String {
	case movie = "movie"
	case music = "music"
	case documentary = "docu"
	case tvshow = "tvshow"
}

enum ItemType: String {
	case movies = "movie"
	case shows = "serial"
	case tvshows = "tvshow"
	case movies3D = "3D" // Prior: 3d
	case concerts = "concert"
	case documentaries = "documovie"
	case series = "docuserial"
	case k4 = "4k"
	init() {
		self = .movies
	}
	func getValue() -> String {
		return self.rawValue
	}
	func genre() -> GenreType {
		switch self {
		case .tvshows:
			return .tvshow
		case .movies, .shows, .movies3D, .k4:
			return .movie
		case .concerts:
			return .music
		case .documentaries, .series:
			return .documentary
		}
	}
}

let moviesSet: Set<ItemType> = [.movies, .movies3D, .concerts, .documentaries, .k4]
let seriesSet: Set<ItemType> = [.shows, .series, .tvshows]


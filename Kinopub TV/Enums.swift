//
//  enums.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation

enum SortOption: String {
	case id = "id"
	case year = "year"
	case title = "title"
	case created = "created"
	case updated = "updated"
	case rating = "rating"
	case views = "view"
	case watchers = "watchers"
	
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
			return "По дате изменения"
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
	case d3 = "3D"
	static let All = [sd, hd, fullHd]
}

enum ItemSubType: String {
	case multi = "multi"
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
		case .movies, .shows, .movies3D:
			return .movie
		case .concerts:
			return .music
		case .documentaries, .series:
			return .documentary
		}
	}
}

let moviesSet: Set<ItemType> = [.movies, .movies3D, .concerts, .documentaries]
let seriesSet: Set<ItemType> = [.shows, .series, .tvshows]

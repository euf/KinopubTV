//
//  Filter.swift
//  Kinopub TV
//
//  Created by Peter on 26.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation

struct Filter: ReflectedStringConvertible {
	var genre: Genre?
	var fromYear: Int?
	var toYear: Int?
	var country: Country?
	var sortBy: SortOption?
	var sortDirection: SortDirection?
	
	static func defaultFilter() -> Filter {
		let filter = Filter(genre: nil, fromYear: 2000, toYear: 2016, country: nil, sortBy: SortOption.updated, sortDirection: .desc)
		return filter
	}
	
	func yearString() -> String {
		return "\(fromYear!)-\(toYear!)"
	}
	
}

extension Filter: Equatable {
	
	static func ==(lhs: Filter, rhs: Filter) -> Bool {
		return lhs.genre == rhs.genre && lhs.genre == rhs.genre && lhs.fromYear == rhs.fromYear && lhs.toYear == rhs.toYear
	}
}


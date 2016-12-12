//
//  ObjectMappable.swift
//  Kinopub TV
//
//  Created by Peter on 11.12.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import ObjectMapper

open class IntTransform: TransformType {
	public typealias Object = Int
	public typealias JSON = String
	
	public init() {}
	
	open func transformFromJSON(_ value: Any?) -> Int? {
		guard let item = value as? String else { return nil }
		return Int(item)

	}
	open func transformToJSON(_ value: Int?) -> String? {
		return nil
	}
}

open class DateIntervalTransform: TransformType {
	public typealias Object = Date
	public typealias JSON = Int
	
	public init() {}
	
	open func transformFromJSON(_ value: Any?) -> Date? {
		guard let intervalValue = value as? Int else { return nil }
		let myDate = Date().addingTimeInterval(TimeInterval(intervalValue))
		return myDate
	}
	open func transformToJSON(_ value: Date?) -> Int? {
		return nil
	}
}

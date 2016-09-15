//
//  Auth.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import ObjectMapper

struct AuthResponse: Mappable {
	
	var code: String?
	var expiration: Date?
	var userCode: String?
	var verificationURI: String?
	
	init?(map:  Map){}
	
	let convertToDate = TransformOf<Date, Int>(fromJSON: { (value: Int?) -> Date? in
		guard let intervalValue = value else { return nil }
		let myDate = Date().addingTimeInterval(TimeInterval(intervalValue))
		return myDate
		}, toJSON: { (value: Date?) -> Int? in
			return nil
	})
	
	mutating func mapping(map: Map) {
		code <- map["code"]
		expiration <- (map["expires_in"], convertToDate)
		userCode <- map["user_code"]
		verificationURI <- map["verification_uri"]
	}
}

struct ActivationResponse: Mappable {
	
	var token: String?
	var expiration: Date?
	var refreshToken: String?
	
	init?(map: Map){}
	
	let convertToDate = TransformOf<Date, Int>(fromJSON: { (value: Int?) -> Date? in
		guard let intervalValue = value else { return nil }
		let myDate = Date().addingTimeInterval(TimeInterval(intervalValue))
		return myDate
		}, toJSON: { (value: Date?) -> Int? in
			return nil
	})
	
	mutating func mapping(map: Map) {
		token <- map["access_token"]
		expiration <- (map["expires_in"], convertToDate)
		refreshToken <- map["refresh_token"]
	}
}

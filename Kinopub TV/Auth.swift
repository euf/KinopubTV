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
	
	mutating func mapping(map: Map) {
		code <- map["code"]
		expiration <- (map["expires_in"], DateIntervalTransform())
		userCode <- map["user_code"]
		verificationURI <- map["verification_uri"]
	}
}

struct ActivationResponse: Mappable {
	
	var token: String?
	var expiration: Date?
	var refreshToken: String?
	
	init?(map: Map){}
	
	mutating func mapping(map: Map) {
		token <- map["access_token"]
		expiration <- (map["expires_in"], DateIntervalTransform())
		refreshToken <- map["refresh_token"]
	}
}

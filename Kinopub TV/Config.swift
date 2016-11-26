//
//  Config.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

struct Config {
	
	static let tintColor = UIColor(red: 0.976, green: 0.329, blue: 0.149, alpha: 1.00)
	static let navBarBackgroundColor = UIColor(red:0.15, green:0.16, blue:0.18, alpha:1.00)
	static let backgroundColor = UIColor(red:0.13, green:0.14, blue:0.15, alpha:1.00)
	
	var appVersion: Float {
		if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			return Float(version)!
		}
		return 0
	}
	
	static let device = utsname().machine
	//static let clientId = "plex"
	//static let clientSecret = "h2zx6iom02t9cxydcmbo9oi0llld7jsv"
	//static let clientId = "appletv"
	//static let clientSecret = "ha19qtm5utnjmj8csv8st3zxefrwpuyk"
	
	//	For AppleTV v4
	static let clientId = "appletv2"
	static let clientSecret = "3z5124kj5liqy9gahnjr07qpj65ferl2"
	
	struct URL {
//		static let base = "https://api.service-kp.com/"
		static let base = "http://api.service-kp.com/"
		static let APIBase = Config.URL.base+"v1"
		static let OAuthBase = Config.URL.base+"oauth2"
		static let madia = "https://media.kino.pub/poster/item"
	}
	
	struct kinopoisk {
		static let base = "https://api.kinopoisk.cf"
	}
	
	struct guideBox {
		static let base = "https://api-public.guidebox.com/v1.43/US/"
		static let key = "rKRMKPD8h6FMnaglY8OhZP4NlI8ZAqXc"
	}
	
	struct themoviedb {
		static let base = "https://api.themoviedb.org/3"
		static let backdropBase = "https://image.tmdb.org/t/p/w1280/"
		static let imageBase = "https://image.tmdb.org/t/p/w1000/"
		static let key = "d5dbe118b642f6c09adf9c45cc6cafdb"
	}
	
}

extension DefaultsKeys {
	static let code = DefaultsKey<String?>("code") // Temporary activation code
	static let token = DefaultsKey<String?>("token") // Access token
	static let refreshToken = DefaultsKey<String?>("refreshToken") // Access token
	static let expiration = DefaultsKey<Date?>("expiration") // Main token expiration time
	static let activationExpiration = DefaultsKey<NSDate?>("activationExpiration") // Activation expiration time
	static let userCode = DefaultsKey<Int?>("userCode") // Device code to activate
	static let verificationURI = DefaultsKey<String?>("verificationURI") // Device code to activate
	static let defaultQuality = DefaultsKey<String?>("defaultQuality") // Default user quality
}

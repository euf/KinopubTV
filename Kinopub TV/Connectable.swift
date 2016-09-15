//
//  Connectable.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SwiftyUserDefaults
import ObjectMapper
import SwiftyJSON

typealias response = (_ result: JSON?, _ error: NSError?) -> ()

enum ResourceMethod: String {
	case get
	case post
}

enum RequestType: String {
	case resource
	case auth
}

struct Request: Connectable {
	var type: RequestType
	var resourceURL: String
	var method: HTTPMethod
	var parameters: [String: AnyObject]?
}

protocol Connectable {
	func performRequest(resource: Request, callback: @escaping response)
}

extension Connectable {
	func performRequest(resource request: Request, callback: @escaping response) {
		
		var url = ""
		var headers: HTTPHeaders = ["Accept": "application/json"]
		
		switch request.type {
		case .resource:
			url = Config.URL.APIBase+request.resourceURL
			headers = ["Authorization": "Bearer \(Defaults[.token]!)"]
			break
		case .auth:
			url = Config.URL.OAuthBase+request.resourceURL
			break
		}
		let method: HTTPMethod = request.method
		Alamofire.request(url, method: method, parameters: request.parameters, encoding: URLEncoding.default, headers: headers)
			.responseJSON { response in
				switch response.result {
				case .success(let data):
					callback(JSON(data), nil)
				case .failure(let error):
					callback(nil, error as NSError?)
				}
		}
	}
	
}

//
//  KinopubLogin.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SwiftyJSON
import ObjectMapper

typealias callback = () -> ()
//typealias LoginValidator = protocol<Authorizable>
//typealias KinopubLoginable = protocol<Tokenable, Deviceable>

enum AuthState {
	case unauthorized
	case expired
	case authorized
//	case error(error: NSError)
}

//extension AuthState: Equatable {
//	static func == (lhs: AuthState, rhs: AuthState) -> Bool {
//		return lhs == rhs
//	}
//}

enum ResponseStatus {
	case success
	case invalid
	case error(error: NSError)
}

enum AuthResponseStatus {
	case success(reponse: AuthResponse)
	case error(error: NSError)
}

enum UserCodeResponse {
	case success
	case invalid
	case pending
	case error(error: NSError)
}

protocol Authorizable: Connectable {
//	var authState: AuthState { get set }
	func checkAuth(callback: @escaping (_ authState: AuthState) -> ()) -> Void
}

extension Authorizable {
	
	func checkAuth(callback: @escaping (_ authState: AuthState) -> ()) {
		log.debug("---> Performing token check")
		
		if Defaults.hasKey(.token), let token = Defaults[.token], let expiration = Defaults[.expiration], let refresh = Defaults[.refreshToken] { // Token has been previouls stored at some point
			
			log.debug("Current token is: \(token)")
			log.debug("Current expiration: \(expiration)")
			log.debug("Our refresh token: \(refresh)")
			log.debug("Checking token validity...")
			
			let typesRequest = Request(type: .resource, resourceURL: "/types", method: .get, parameters: nil)
			performRequest(resource: typesRequest) { result, error in
				switch (result, error) {
				case(let result?, _):
					log.info("Got token response..")
					if result["status"] == 200 {
						callback(.authorized)
					} else {
						callback(.expired)
					}
				case(_, let error?):
					log.error("Error accessing the service \(error)")
//					callback(.error(error: error))
					break
				default: break
				}
			}
		} else {
			callback(.unauthorized)
		}
	}
}

protocol DeviceTokenable: Connectable {
	func refreshToken(callback: @escaping (_ status: ResponseStatus) -> ()) -> Void
	func saveToken(response: ActivationResponse)
	func requestDeviceAuthorization(callback: @escaping (_ status: AuthResponseStatus) -> ()) -> Void
	func validateUserCode(code: String, callback: @escaping (_ status: UserCodeResponse) -> ()) -> Void
	func registerDevice()
}

extension DeviceTokenable {
	
	func refreshToken(callback: @escaping (ResponseStatus) -> ()) {
		log.debug("Attempting to refresh the token")
		if Defaults.hasKey(.refreshToken), let refresh = Defaults[.refreshToken] {
			let parameters = [
				"grant_type": "refresh_token",
				"client_id": Config.clientId,
				"client_secret": Config.clientSecret,
				"refresh_token": refresh
			]
			let refreshTokenRequest = Request(type: .auth, resourceURL: "/token", method: .post, parameters: parameters as [String : AnyObject]?)
			performRequest(resource: refreshTokenRequest) { result, error in
				switch (result, error) {
				case(let result?, _):
					log.debug("Response for refreshing token: \(result)")
					if result["status"] != 400, let response = Mapper<ActivationResponse>().map(JSONObject: result.dictionaryObject) {
						log.debug("Mapped refresh token. And saving..")
						self.saveToken(response: response)
						callback(.success)
					} else {
						log.warning("Mapping refresh failed")
						callback(.invalid)
					}
				case(_, let error?):
					log.error("Error accessing the service \(error)")
					callback(.error(error: error))
					break
				default: break
				}
			}
		} else {
			log.debug("We don't actually have a refresh token. Something went wrong!")
			callback(.invalid)
		}
	}
	
	func saveToken(response: ActivationResponse) {
		log.debug("New token: \(response.token)")
		log.debug("New refresh token: \(response.refreshToken)")
		log.debug("New token expiration: \(response.expiration)")
		Defaults[.token] = response.token
		Defaults[.expiration] = response.expiration as Date?
		Defaults[.refreshToken] = response.refreshToken
	}
	
	func requestDeviceAuthorization(callback: @escaping (_ status: AuthResponseStatus) -> ()) {
		log.debug("Requesting authorization for a new device")
		let parameters = [
			"grant_type": "device_code",
			"client_id": Config.clientId,
			"client_secret": Config.clientSecret
		]
		let authRequest = Request(type: .auth, resourceURL: "/device", method: .post, parameters: parameters as [String : AnyObject]?)
		performRequest(resource: authRequest) { result, error in
			switch (result, error) {
			case(let result?, _):
				if let response = Mapper<AuthResponse>().map(JSONObject: result.dictionaryObject) {
					callback(.success(reponse: response))
				} else {
					// This is where client id and secret are no longer valid on the Kinopub
					log.debug("Unable to map the response")
					log.debug(result)
				}
				break
			case(_, let error?):
				log.error("Error accessing the service: \(error)")
				callback(.error(error: error))
				break
			default: break
			}
		}
	}
	
	func validateUserCode(code: String, callback: @escaping (_ status: UserCodeResponse) -> ()) {
		log.info("Validating device authorization")
		let parameters = [
			"grant_type": "device_token",
			"client_id": Config.clientId,
			"client_secret": Config.clientSecret,
			"code": code
		]
		let authDeviceRequest = Request(type: .auth, resourceURL: "/device", method: .post, parameters: parameters as [String : AnyObject]?)
		performRequest(resource: authDeviceRequest) { result, error in
			switch (result, error) {
			case(let result?, _):
				if result["status"] != 400 && result["access_token"] != "", let response = Mapper<ActivationResponse>().map(JSONObject: result.dictionaryObject) {
					log.debug("Validation went fine")
					self.saveToken(response: response)
					self.registerDevice()
					callback(.success)
				} else if result["error"] == "bad_verification_code" {
					log.debug("Bad verificatin code")
					callback(.invalid)
				} else if result["error"] == "authorization_pending" {
					log.debug("Validation still pending")
					callback(.pending)
				} else {
					log.warning("Unknown response. Reauthorizing.. ")
					callback(.invalid)
				}
				break
			case(_, let error?):
				log.error("Error accessing the service: \(error)")
				callback(.error(error: error))
				break
			default: break
			}
		}
	}
	
	func registerDevice() {
		let parameters = [
			"title": UIDevice().name,
			"hardware": UIDevice().deviceType,
			"software": UIDevice().systemName+"/"+UIDevice().systemVersion+" "+"KinopubTV/2.0"
		]
		let deviceRequest = Request(type: .resource, resourceURL: "/device/notify", method: .post, parameters: parameters as [String : AnyObject]?)
		performRequest(resource: deviceRequest) { result, error in
			log.info("Registering device with Kinopub")
			switch (result, error) {
			case(let result?, _):
				log.debug("Device registered: \(result)")
				break
			case(_, let error?):
				log.error("Error accessing the service: \(error)")
				break
			default: break
			}
		}
	}
}

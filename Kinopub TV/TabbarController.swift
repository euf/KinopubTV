//
//  TabbarController.swift
//  Kinopub TV
//
//  Created by Peter on 15/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Crashlytics

class TabbarController: PITabBarController, Authorizable, DeviceTokenable {
	
	let center = NotificationCenter.default
	var authState = AuthState.unauthorized // When starting we're unauthorized by default
	
	override func viewDidLoad() {
		super.viewDidLoad()
		center.addObserver(self, selector: #selector(TabbarController.appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
		prepareNavigation()
	}
	
	func appDidBecomeActive() {
		checkActivationStatus()
	}
	
	private func prepareNavigation() {
		self.viewControllers = [
			getViewController(identifier: "newController")!,
			getViewController(identifier: "picksController")!,
			getViewController(identifier: "watchController")!,
			getViewController(identifier: "tvController")!,
//			getViewController(identifier: "searchController")!,
			getViewController(identifier: "profileController")!,
			//			getViewController("SearchViewController")!,
			//			getViewController("SettingsViewController")!,
		]
		
		self.tabBar.updateDisplay()
		self.tabBar.itemSpacing = 40
		self.tabBar.itemOffset = 40
	}
	
	/**
	Called on startup to check current device activation state
	*/
	private func checkActivationStatus() {
		log.info("Checking activation status")
		checkAuth() {state in
			switch state {
			case .authorized:
				log.debug("All good. We're authorized")
				// Interested in authorized stuff here
				self.setQuality()
				Answers.logLogin(withMethod: "token access", success: 1, customAttributes: nil)
				break
			case .expired: // Attempting to auto refresh the expired token
				self.refreshToken() { status in
					switch status {
					case .success:
						Answers.logLogin(withMethod: "token refresh", success: 1, customAttributes: nil)
						// Managed to refresh token
						self.setQuality()
						break
					default:
						Answers.logLogin(withMethod: "token refresh", success: 0, customAttributes: nil)
						self.showLoginController(state: state)
						break
					}
				}
				break
			default:
				log.debug("We do not have a valid access or refresh token")
				Answers.logLogin(withMethod: "token access", success: 0, customAttributes: ["Needs re-activation":true])
				self.showLoginController(state: state)
				break
			}
		}
	}
	
	/**
	Displaying login controller
	- parameter state: Current (non working state)
	*/
	private func showLoginController(state: AuthState) {
		self.authState = state
		DispatchQueue.main.async {
			if let loginController = self.storyboard?.instantiateViewController(withIdentifier: "loginWindow") as? LoginViewController {
				loginController.authState = state
				self.present(loginController, animated: true, completion: nil)
			}
		}
	}
	
	private func setQuality() {
		// Устанавливаем дефалтовое качество если он не установлено все еще
		if !Defaults.hasKey(.defaultQuality) {
			Defaults[.defaultQuality] = Quality.hd.rawValue
		}
		log.debug("Current default quality: \(Quality(rawValue: Defaults[.defaultQuality]!))")
	}
	
}

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
			getViewController(identifier: "bookmarksController")!,
			getViewController(identifier: "profileController")!,
			getViewController(identifier: "searchController")!,
			// getViewController("SettingsViewController")!,
		]
		self.tabBar.updateDisplay()
		self.tabBar.itemSpacing = 40
		self.tabBar.itemOffset = 40
	}
	
	
	/// This method is called to update HomeViewController after token refresh (which takes more time than validity check)
	fileprivate func refreshHomeScreen() {
		if let homeController = viewControllers.first as? HomeViewController {
			if authState == .authorized {
				log.debug("Authorized. Fetching home content")
				homeController.loadFeaturedMovies()
				homeController.loadFeaturedShows()
			}
		}
	}
	
	/**
	Called on startup to check current device activation state
	*/
	private func checkActivationStatus() {
		log.info("Checking activation status")
		checkAuth() {state in
			authState = state
			switch state {
			case .authorized:
				log.debug("All good. We're authorized")
				self.setQuality()
				self.refreshHomeScreen() // This is needed when refresh is initiated and our home screen is empty
				Answers.logLogin(withMethod: "token access", success: 1, customAttributes: nil)
				break
			case .expired: // Attempting to auto refresh the expired token
				self.refreshToken() { status in
					switch status {
					case .success:
						Answers.logLogin(withMethod: "token refresh", success: 1, customAttributes: nil)
						self.refreshHomeScreen() // This is needed when refresh is initiated and our home screen is empty
						self.setQuality()
						break
					default:
						Answers.logLogin(withMethod: "token refresh", success: 0, customAttributes: nil)
						self.showLoginController(state: state)
						break
					}
				}
				break
			case .unauthorized:
				log.debug("We do not have a valid access or refresh token")
				Answers.logLogin(withMethod: "token access", success: 0, customAttributes: ["Needs re-activation":true])
				self.showLoginController(state: state)
				break
//			case .error(let error):
//				log.debug("Error performing token activation status check: \(error)")
//				break
			}
			
		}
	}
	
	/**
	Displaying login controller
	- parameter state: Current (non working state)
	*/
	private func showLoginController(state: AuthState) {
		log.debug("Presenting login controller")
		authState = state
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

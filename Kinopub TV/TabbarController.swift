//
//  TabbarController.swift
//  Kinopub TV
//
//  Created by Peter on 15/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class TabbarController: PITabBarController, Authorizable, DeviceTokenable {
	
	var authState = AuthState.unauthorized // When starting we're unauthorized by default
	
	override func viewDidLoad() {
		super.viewDidLoad()
		prepareNavigation()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		checkActivationStatus()
	}
	
	private func prepareNavigation() {
		self.viewControllers = [
			getViewController(identifier: "newController")!,
			getViewController(identifier: "picksController")!,
			getViewController(identifier: "listController")!,
			getViewController(identifier: "listController")!,
			getViewController(identifier: "listController")!,
			getViewController(identifier: "listController")!,
			getViewController(identifier: "listController")!,
			getViewController(identifier: "listController")!,
			//			getViewController("SearchViewController")!,
			//			getViewController("SettingsViewController")!,
		]
		
		for (index, c) in self.viewControllers.enumerated() {
			if let controller = c as? ListViewController {
				
				switch(index) {
				case 2:
					//					controller.currentView = .Movies
					controller.tabBarItem.title = "Фильмы"
					break
				case 3:
					//					controller.currentView = .Shows
					controller.tabBarItem.title = "Сериалы"
					break
				case 4:
					//					controller.currentView = .Movies3D
					controller.tabBarItem.title = "3D"
					break
				case 5:
					//					controller.currentView = .Concerts
					controller.tabBarItem.title = "Концерты"
					break
				case 6:
					//					controller.currentView = .Documentaries
					controller.tabBarItem.title = "Докуфильмы"
					break
				case 7:
					//					controller.currentView = .Series
					controller.tabBarItem.title = "Докусериалы"
					break
				default: return
				}
			}
		}
		
		self.tabBar.updateDisplay()
		self.tabBar.itemSpacing = 40
		self.tabBar.itemOffset = 40
	}
	
	/**
	Called on startup to check current device activation state
	*/
	private func checkActivationStatus() {
		checkAuth() {state in
			switch state {
			case .authorized:
				log.debug("All good. We're authorized")
				// Interested in authorized stuff here
				self.setQuality()
				break
			case .expired: // Attempting to auto refresh the expired token
				self.refreshToken() { status in
					switch status {
					case .success:
						// Managed to refresh token
						self.setQuality()
						break
					default:
						self.showLoginController(state: state)
						break
					}
				}
				break
			default:
				log.debug("We do not have a valid access or refresh token")
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

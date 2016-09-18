//
//  LoginViewController.swift
//  Kinopub TV
//
//  Created by Peter on 18/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, DeviceTokenable {
	
	var authState: AuthState?
	var authCode = ""

	@IBOutlet var codeText: UILabel!
	@IBOutlet var errorText: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		if let state = authState {
			log.info("Launching login controller. Current auth state: \(state)")
			authorizeDevice(state: state)
		}
    }
	
	func authorizeDevice(state: AuthState) {
		log.debug("Authorizing device after expiration or de-auth")
		errorText.text = ""
		switch state {
		case .expired:
			refreshToken() { status in
				switch status {
				case .success:
					log.debug("Got success. Should dismiss")
					self.dismiss(animated: true, completion: nil)
					break
				case .invalid:
					log.warning("Got invalid state")
					self.authorizeDevice(state: .unauthorized)
					break
				case .error(let error):
					log.error(error)
					break
				}
			}
			break
		case .unauthorized:
			requestDeviceAuthorization() { status in
				if case .success(let response) = status {
					if let code = response.userCode, let authCode = response.code {
						self.codeText.text = code
						self.authCode = authCode
//						self.urlLabel.text = url
					}
				}
			}
			break
		default: break
			// Re-request all token
		}
	}
	
	@IBAction func checkActivation(_ sender: AnyObject) {
		errorText.text = "" // Clear text label
		validateUserCode(code: authCode) { response in
			switch response {
			case .success:
				self.dismiss(animated: true, completion: nil)
				break
			case .invalid:
				self.errorText.text = "Неверный или устаревший код запроса"
				delay(delay: 2) { self.authorizeDevice(state: .unauthorized) }
				break
			case .pending:
				self.errorText.text = "Код еще не подтвержден. Перейдите на страницу подстверждения и введите код."
				break
			case .error(let error):
				self.errorText.text = "Ошибка подключения. Вероятно нет соединения с интернетом."
				log.error("Network request error: \(error)")
				break
			}
		}
	}
	
	@IBAction func requestNewCode(_ sender: AnyObject) {
		self.authorizeDevice(state: .unauthorized)
	}
	
}

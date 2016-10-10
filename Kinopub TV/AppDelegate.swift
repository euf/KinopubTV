//
//  AppDelegate.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyBeaver
import Fabric
import Crashlytics

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		Fabric.with([Crashlytics.self, Answers.self])
		let console = ConsoleDestination()  // log to Xcode Console
		console.levelString.verbose = "😺 VERBOSE"
		console.levelString.debug = "😹 DEBUG"
		console.levelString.info = "😼 INFO"
		console.levelString.warning = "😾 WARNING"
		console.levelString.error = "🙀 ERROR"
		let file = FileDestination()  // log to default swiftybeaver.log file
		log.addDestination(console)
		log.addDestination(file)
		//let platform = SBPlatformDestination(appID: "lRPP6J", appSecret: "9ghrvwwTp8xnaxkiq6Ob9qryqjkWeaug", encryptionKey: "spelpOLejqpph4wema3f0idvy1NuoDzj")
		//log.addDestination(platform)
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}


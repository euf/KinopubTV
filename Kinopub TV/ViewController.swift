//
//  ViewController.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		log.verbose("not so important")  // prio 1, VERBOSE in silver
		log.debug("something to debug")  // prio 2, DEBUG in blue
		log.info("a nice information")   // prio 3, INFO in green
		log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
		log.error("ouch, an error did occur!")  // prio 5, ERROR in red
		
		log.verbose(123)
		log.info(-123.45678)
		log.warning(NSDate())
		log.error(["I", "like", "logs!"])
		log.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}


//
//  Common.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation

func delay(delay: Double, closure: @escaping ()->()) {
	let when = DispatchTime.now() + delay
	DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

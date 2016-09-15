//
//  Extensions.swift
//  Kinopub TV
//
//  Created by Peter on 14/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//


import UIKit

public extension UIDevice {
	
	var deviceType: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		
		let machine = systemInfo.machine
		let mirror = Mirror(reflecting: machine)
		var identifier = ""
		
		for child in mirror.children {
			if let value = child.value as? Int8 , value != 0 {
				let v = UnicodeScalar(UInt8(value))
				identifier.append(String(v))
			}
		}
		
		if identifier == "x86_64" {
			return "iOS Simulator"
		}
		
		return identifier
	}
}

extension String {
	func stripHTML() -> String {
		let htmlStringData = self.data(using: String.Encoding.utf8)!
		let attributedHTMLString = try! NSAttributedString(
			data: htmlStringData,
			options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8],
			documentAttributes: nil
		)
		return attributedHTMLString.string
	}
}

extension UISegmentedControl {
	func replaceSegments(segments: Array<String>) {
		self.removeAllSegments()
		for segment in segments {
			self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
		}
	}
}

extension Array {
	
	func takeElements( element: Int) -> Array {
		var elementCount = element
		if (elementCount > count) {
			elementCount = count
		}
		return Array(self[0..<elementCount])
	}
	
	subscript (safe index: Int) -> Element? {
		return indices ~= index ? self[index] : nil
	}
	
	func atIndex(index: Int) -> Element? {
		if index < 0 || index > self.count - 1 {
			return nil
		}
		return self[index]
	}
	
	func slice(args: Int...) -> Array {
		var s = args[0]
		var e = self.count - 1
		if args.count > 1 { e = args[1] }
		
		if e < 0 {
			e += self.count
		}
		
		if s < 0 {
			s += self.count
		}
		
		let count = (s < e ? e-s : s-e)+1
		let inc = s < e ? 1 : -1
		var ret = Array()
		
		var idx = s
		for _ in 0 ..< count  {
			ret.append(self[idx])
			idx += inc
		}
		return ret
	}
}
